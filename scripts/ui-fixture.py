#!/usr/bin/env python3
"""Loopback-only, deterministic UI fixture. Never used by the application runtime."""
import json
from email.parser import BytesParser
from email.policy import default
from pathlib import Path
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import threading
import time
from urllib.parse import parse_qs, urlsplit
from uuid import uuid4

SERVER = '11111111-1111-4111-8111-111111111111'
EPOCH = '33333333-3333-4333-8333-333333333333'
CLIENT = '22222222-2222-4222-8222-222222222222'
condition = threading.Condition(threading.RLock())
state = {}


def now():
    return int(time.time() * 1000)


def reset():
    state.clear()
    state.update(image_sends=[], uploads=0, memory_corrected=False, memory_deleted=False, sequence=0, sends=0, ask=False, permission=False, task=False, read=False, offline=False,
                 sessions={'fixture-session': [{'role': 'assistant', 'kind': 'message', 'content': 'What would make today a good day?',
                                                'timestamp': now(), 'message_id': 'welcome', 'message_kind': 'assistant_final'}]})


def changed():
    state['sequence'] += 1
    condition.notify_all()


def task():
    return dict(id='fixture-task', title='Review the iOS boundary', body_md='Check the client contract and recovery behavior.',
                user_id='default', origin='user', status='completed' if state['task'] else 'active', version=2 if state['task'] else 1,
                created_at=time.time(), updated_at=time.time())


class Handler(BaseHTTPRequestHandler):
    protocol_version = 'HTTP/1.1'

    def log_message(self, *args):
        pass

    def respond(self, data, code=200):
        raw = json.dumps(data).encode()
        self.send_response(code)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', str(len(raw)))
        self.end_headers()
        self.wfile.write(raw)

    def do_GET(self):
        try:
            self.route('GET')
        except (BrokenPipeError, ConnectionResetError):
            pass

    def do_DELETE(self):
        self.route("DELETE")

    def do_POST(self):
        try:
            self.route('POST')
        except (BrokenPipeError, ConnectionResetError):
            pass

    def route(self, method):
        url = urlsplit(self.path)
        path, query = url.path, parse_qs(url.query)
        raw_body = self.rfile.read(int(self.headers.get('Content-Length', '0')))
        multipart = None
        if self.headers.get('Content-Type', '').startswith('multipart/form-data'):
            multipart = BytesParser(policy=default).parsebytes(('Content-Type: ' + self.headers['Content-Type'] + '\r\n\r\n').encode() + raw_body)
            body = {}
        else:
            body = json.loads(raw_body or '{}')
        if path == '/api/events':
            if self.headers.get('x-magi-session-token') != 'fixture-access':
                return self.respond({}, 401)
            self.send_response(200)
            self.send_header('Content-Type', 'text/event-stream')
            self.send_header('Cache-Control', 'no-cache')
            self.end_headers()
            previous = -1
            while True:
                with condition:
                    seq = state['sequence']
                    event = dict(contract_version=1, server_id=SERVER, epoch=EPOCH, sequence=seq, event_id=f'{EPOCH}:{seq}',
                                 event_type='resync_required' if previous == -1 else 'state.changed',
                                 data={'reason': 'initial'} if previous == -1 else {'resource': 'messages'})
                    if previous != seq:
                        self.wfile.write(f'data: {json.dumps(event)}\n\n'.encode())
                    else:
                        self.wfile.write(b': heartbeat\n\n')
                    self.wfile.flush()
                    previous = seq
                    condition.wait(timeout=3)
        with condition:
            if path == '/test/reset':
                reset()
                return self.respond({})
            if path == '/test/images':
                state['sessions']['fixture-session'][0]['attachments'] = [dict(attachment_id='fixture-image', kind='image', mime_type='image/png', original_name='Magi.png')]
                return self.respond({'ok': True})
            if path == '/test/state':
                return self.respond({k: v for k, v in state.items() if k != 'sessions'})
            if path in ['/test/offline', '/test/online']:
                state['offline'] = path == '/test/offline'
                return self.respond({})
            if path == '/test/interactions':
                state['ask'] = True
                return self.respond({})
            if path == '/api/auth/pair':
                if self.headers.get('x-magi-session-token') != 'a' * 64:
                    return self.respond({}, 401)
                return self.respond({'success': True, 'data': dict(server_id=SERVER, client_id=CLIENT, client_credential='fixture-credential')})
            if path == '/api/auth/session':
                if self.headers.get('x-magi-session-token') != 'fixture-credential':
                    return self.respond({}, 401)
                return self.respond({'success': True, 'data': dict(server_id=SERVER, client_id=CLIENT, access_token='fixture-access', expires_at_ms=now() + 3600000)})
            if self.headers.get('x-magi-session-token') != 'fixture-access':
                return self.respond({}, 401)
            if state['offline']:
                return self.respond({'error': 'service unavailable'}, 503)
            if path == '/api/messages/session/fixture-session/attachments/fixture-image/content':
                raw = (Path(__file__).resolve().parents[1] / 'MagiIOS/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png').read_bytes()
                self.send_response(200)
                self.send_header('Content-Type', 'image/png')
                self.send_header('Content-Length', str(len(raw)))
                self.end_headers()
                self.wfile.write(raw)
                return
            if path.endswith('/attachments') and method == 'POST':
                parts = {part.get_param('name', header='Content-Disposition'): part for part in multipart.iter_parts()}
                data = parts['file'].get_payload(decode=True)
                assert parts['file'].get_content_type() == 'image/jpeg' and data.startswith(b'\xff\xd8')
                state['uploads'] += 1
                attachment = dict(attachment_id='fixture-image', kind='image', mime_type='image/jpeg', original_name=parts['file'].get_filename(), size_bytes=len(data))
                return self.respond(dict(success=True, data=dict(session_id=path.split('/')[4], turn_id=parts['turn_id'].get_content(), attachment=attachment)))
            if path == '/api/server/info':
                return self.respond({'success': True, 'data': dict(server_id=SERVER, protocol_version=3, service_ready=True,
                    plugin_execution='server', supervisor={}, events=dict(epoch=EPOCH, sequence=state['sequence']),
                    client_contract=dict(version=1, product_events='/api/events?scope=product', diagnostic_events='/api/events?scope=diagnostics', schema='/api/openapi.json'),
                    maintenance=dict(version=2, data_epoch=EPOCH, content_epoch=EPOCH, phase='idle', kind=None, operation_id=None, result=None, error=None))})
            if path == '/api/memory/library':
                about = dict(id='walking', kind='fact', text='You enjoy evening walks.', assertion_id='walking', evidence_ids=['walk-event'])
                event = dict(id='walk-event', kind='event', text='An evening walk by the river.', timestamp=time.time(), can_delete=True, source='manual')
                items = ([about] if not state['memory_corrected'] else []) if query.get('view', ['about'])[0] == 'about' else ([event] if not state['memory_deleted'] else [])
                return self.respond(dict(items=items, total=len(items), limit=40, offset=0, stale=False))
            if path == '/api/memory/library/evidence/walk-event':
                return self.respond(dict(id='walk-event', kind='event', text='An evening walk by the river.', timestamp=time.time(), can_delete=True, source='manual'))
            if path == '/api/memory/l2/corrections':
                state['memory_corrected'] = True
                return self.respond(dict(created=True, derivation_state='pending', correction=dict(correction_id='correction-1', correction_kind='record_error', created_at=time.time(), state='active')))
            if path == '/api/memory/l1/events/walk-event' and method == 'DELETE':
                state['memory_deleted'] = True
                return self.respond(dict(event_id='walk-event', deleted=True, deletion_scope='source_event'))
            if path == '/api/plugins':
                manifest = dict(plugin_id='apple-health', name='Apple Health', version='0.1.0', description='Steps, sleep and workouts shared from your iPhone', author='Magi Team', official=True,
                                protocol_version=2, min_sdk_version='0.2.6', execution_mode='trusted_process', settings_fields=[], contribution_types=['source'], source='external', plugin_dir='', manifest_path='',
                                device_collectors=[dict(source_type='apple_health', capability_id='apple_health.observe', protocol='source.change.v1', schema_id='apple_health.record', schema_version=1, platforms=['ios'])])
                return self.respond(dict(plugins=[dict(manifest=manifest, enabled=True, trusted=True, loaded=True, healthy=True, package_sha256='a'*64)], total=1))
            if path == '/api/plugins/registry':
                return self.respond(dict(registry_version='4', install_fingerprint='a'*64, plugins=[dict(plugin_id='apple-health', name='Apple Health', version='0.1.0', description='Steps, sleep and workouts shared from your iPhone',
                    protocol_version=2, execution_mode='trusted_process', min_sdk_version='0.2.6', installed=True)]))
            if path == '/api/plugins/apple-health/connections':
                return self.respond(dict(connections=[], total=0))
            if path == '/api/messages/sessions':
                items = [dict(session_id=k, title='A clearer day' if k == 'fixture-session' else 'New conversation',
                              last_message_preview=v[-1]['content'] if v else '', last_user_message_preview='', title_overridden=False,
                              last_timestamp=v[-1]['timestamp'] if v else now(), message_count=len(v)) for k, v in state['sessions'].items()]
                return self.respond(dict(user_id='default', sessions=items, count=len(items), revision=str(state['sequence']), not_modified=False, has_more=False, next_before=None))
            if path == '/api/messages/session/new':
                sid = query.get('idempotency_key', [str(uuid4())])[0]
                state['sessions'].setdefault(sid, [])
                changed()
                return self.respond(dict(success=True, session_id=sid, user_id='default', workspace_path=None), 201)
            if path == '/api/messages/history':
                sid = query['session_id'][0]
                items = state['sessions'].get(sid, [])
                return self.respond(dict(user_id='default', session_id=sid, messages=items, count=len(items), history_version=len(items),
                                         context_usage=None, revision=str(state['sequence']), not_modified=False, has_more=False, next_before=None))
            if path == '/api/messages/send':
                state['sends'] += 1
                if body.get('attachments'): state['image_sends'].append(dict(text=body['message'], count=len(body['attachments'])))
                sid, tid, text = body['session_id'], body['client_turn_id'], body['message']
                state['sessions'][sid] += [dict(role='user', kind='message', content=text, timestamp=now(), message_id='user-' + tid, turn_id=tid, attachments=body.get('attachments', [])),
                                           dict(role='assistant', kind='message', message_kind='assistant_final', content='Received: ' + text, timestamp=now()+1,
                                                message_id='reply-' + tid, turn_id=tid)]
                changed()
                # Simulate a successful mutation followed by a lost acknowledgement.
                return self.respond({'error': 'acknowledgement unavailable'}, 502)
            if path == '/api/messages/confirmation':
                sid, tid = body['session_id'], body.get('turn_id') or body.get('request_id')
                present = any(m.get('turn_id') == tid for m in state['sessions'].get(sid, [])) or body['kind'] == 'ask_response'
                return self.respond(dict(session_id=sid, identity=tid, status='confirmed' if present else 'absent', safe_to_retry=not present))
            if '/turn/' in path:
                sid, tid = path.split('/')[4], path.split('/')[-1]
                return self.respond(dict(session_id=sid, turn_id=tid, acceptance='accepted', state='completed', terminal=True,
                                         response_complete=True, presentation_ends_at_ms=None, can_resubmit=False, revision='1'))
            if path.endswith('/ask'):
                return self.respond({'ask': dict(request_id='fixture-ask', question='What should we work on first?', options=['Start with iOS'],
                                                 allow_free_text=False, status='pending') if state['ask'] else None})
            if path.endswith('/permissions'):
                return self.respond({'items': [dict(request_id='fixture-permission', tool_name='file_write', preview='Write the iOS review notes',
                                                   arguments={'path': 'review.txt', 'content': 'Contract reviewed.'})] if state['permission'] else []})
            if path == '/api/control/ask/fixture-ask/respond':
                state['ask'] = False
                state['permission'] = True
                changed()
                return self.respond(dict(resolved=True, request_id='fixture-ask'))
            if path == '/api/control/permission/fixture-permission/respond':
                state['permission'] = False
                changed()
                return self.respond(dict(resolved=True, request_id='fixture-permission'))
            if path == '/api/personal-tasks':
                completed = query.get('view', ['next'])[0] == 'completed'
                items = [task()] if completed == state['task'] else []
                return self.respond(dict(items=items, total=len(items), next_offset=None, counts={'next': 0 if state['task'] else 1, 'completed': 1 if state['task'] else 0}))
            if path == '/api/personal-tasks/mutations':
                if body['expected_version'] != task()['version']:
                    return self.respond({}, 409)
                state['task'] = True
                changed()
                return self.respond(dict(item=task(), deleted_ids=[], reminders_pending=False, replayed=False))
            if path == '/api/notifications':
                item = dict(id=1, kind='personal_task_reminder', dedupe_key='test-reminder', title='A small reminder', body='Take a moment to review your next step.',
                            payload={'personal_item_id': 'fixture-task'}, status='read' if state['read'] else 'unread', created_at_ms=now(), read_at_ms=now() if state['read'] else None)
                return self.respond(dict(items=[item], total=1, unread_count=0 if state['read'] else 1))
            if path == '/api/notifications/mark-read':
                state['read'] = True
                changed()
                return self.respond({'updated': 1})
            return self.respond({'error': 'unimplemented fixture route'}, 404)


if __name__ == '__main__':
    reset()
    ThreadingHTTPServer(('127.0.0.1', 18992), Handler).serve_forever()
