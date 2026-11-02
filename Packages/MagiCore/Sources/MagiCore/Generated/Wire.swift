// Generated from Contracts/product-api.json. Do not edit.
import Foundation

public enum Wire {
    public struct AccessResponse: Codable, Sendable, Equatable {
        public var `data`: GatewayAccessSession
        public var `success`: Bool
        public init(`data`: GatewayAccessSession, `success`: Bool) {
            self.`data` = `data`
            self.`success` = `success`
        }
    }
    public struct AnswerConfirmationRequest: Codable, Sendable, Equatable {
        public var `answer`: String
        public var `kind`: String
        public var `request_id`: String
        public var `session_id`: String
        public init(`answer`: String, `kind`: String, `request_id`: String, `session_id`: String) {
            self.`answer` = `answer`
            self.`kind` = `kind`
            self.`request_id` = `request_id`
            self.`session_id` = `session_id`
        }
    }
    public typealias AskSnapshot = [String: JSONValue]
    public struct Body_upload_chat_attachment_api_messages_session__session_id__attachments_post: Codable, Sendable, Equatable {
        public var `file`: String
        public var `turn_id`: String
        public var `user_id`: String?
        public init(`file`: String, `turn_id`: String, `user_id`: String? = nil) {
            self.`file` = `file`
            self.`turn_id` = `turn_id`
            self.`user_id` = `user_id`
        }
    }
    public struct CancelSessionRunRequest: Codable, Sendable, Equatable {
        public var `reason`: String?
        public var `requested_by`: String?
        public var `turn_id`: String?
        public var `user_id`: String?
        public init(`reason`: String? = nil, `requested_by`: String? = nil, `turn_id`: String? = nil, `user_id`: String? = nil) {
            self.`reason` = `reason`
            self.`requested_by` = `requested_by`
            self.`turn_id` = `turn_id`
            self.`user_id` = `user_id`
        }
    }
    public struct ChatContextUsageResponse: Codable, Sendable, Equatable {
        public var `input_capacity`: Int64
        public var `measurement`: String
        public var `model_id`: String?
        public var `model_provider`: String?
        public var `session_id`: String
        public var `threshold`: Int64
        public var `turn_id`: String
        public var `updated_at_ms`: Int64
        public var `used_tokens`: Int64
        public var `user_id`: String
        public var `window_size`: Int64
        public init(`input_capacity`: Int64, `measurement`: String, `model_id`: String? = nil, `model_provider`: String? = nil, `session_id`: String, `threshold`: Int64, `turn_id`: String, `updated_at_ms`: Int64, `used_tokens`: Int64, `user_id`: String, `window_size`: Int64) {
            self.`input_capacity` = `input_capacity`
            self.`measurement` = `measurement`
            self.`model_id` = `model_id`
            self.`model_provider` = `model_provider`
            self.`session_id` = `session_id`
            self.`threshold` = `threshold`
            self.`turn_id` = `turn_id`
            self.`updated_at_ms` = `updated_at_ms`
            self.`used_tokens` = `used_tokens`
            self.`user_id` = `user_id`
            self.`window_size` = `window_size`
        }
    }
    public struct ChatDisplayMessage: Codable, Sendable, Equatable {
        public var `allow_trace_collapse`: Bool?
        public var `attachments`: [[String: JSONValue]]?
        public var `content`: String
        public var `kind`: String
        public var `label`: [String: JSONValue]?
        public var `message_id`: String?
        public var `message_kind`: String?
        public var `payload`: [String: JSONValue]?
        public var `persona_id`: String?
        public var `reply_to`: [String: JSONValue]?
        public var `role`: String
        public var `run_state`: [String: JSONValue]?
        public var `timestamp`: Int64
        public var `trace_available`: Bool?
        public var `trace_display_mode`: String?
        public var `trace_summary`: [String: JSONValue]?
        public var `turn_id`: String?
        public init(`allow_trace_collapse`: Bool? = nil, `attachments`: [[String: JSONValue]]? = nil, `content`: String, `kind`: String, `label`: [String: JSONValue]? = nil, `message_id`: String? = nil, `message_kind`: String? = nil, `payload`: [String: JSONValue]? = nil, `persona_id`: String? = nil, `reply_to`: [String: JSONValue]? = nil, `role`: String, `run_state`: [String: JSONValue]? = nil, `timestamp`: Int64, `trace_available`: Bool? = nil, `trace_display_mode`: String? = nil, `trace_summary`: [String: JSONValue]? = nil, `turn_id`: String? = nil) {
            self.`allow_trace_collapse` = `allow_trace_collapse`
            self.`attachments` = `attachments`
            self.`content` = `content`
            self.`kind` = `kind`
            self.`label` = `label`
            self.`message_id` = `message_id`
            self.`message_kind` = `message_kind`
            self.`payload` = `payload`
            self.`persona_id` = `persona_id`
            self.`reply_to` = `reply_to`
            self.`role` = `role`
            self.`run_state` = `run_state`
            self.`timestamp` = `timestamp`
            self.`trace_available` = `trace_available`
            self.`trace_display_mode` = `trace_display_mode`
            self.`trace_summary` = `trace_summary`
            self.`turn_id` = `turn_id`
        }
    }
    public struct ChatSessionSummary: Codable, Sendable, Equatable {
        public var `history_version`: Int64?
        public var `last_message_preview`: String
        public var `last_timestamp`: Int64
        public var `last_user_message_preview`: String
        public var `message_count`: Int64
        public var `session_id`: String
        public var `title`: String
        public var `title_overridden`: Bool
        public var `workspace_path`: String?
        public init(`history_version`: Int64? = nil, `last_message_preview`: String, `last_timestamp`: Int64, `last_user_message_preview`: String, `message_count`: Int64, `session_id`: String, `title`: String, `title_overridden`: Bool, `workspace_path`: String? = nil) {
            self.`history_version` = `history_version`
            self.`last_message_preview` = `last_message_preview`
            self.`last_timestamp` = `last_timestamp`
            self.`last_user_message_preview` = `last_user_message_preview`
            self.`message_count` = `message_count`
            self.`session_id` = `session_id`
            self.`title` = `title`
            self.`title_overridden` = `title_overridden`
            self.`workspace_path` = `workspace_path`
        }
    }
    public struct ClearHistoryResponse: Codable, Sendable, Equatable {
        public var `cleanup_pending`: Bool?
        public var `cleared_message_ids`: [String]?
        public var `cleared_turn_ids`: [String]?
        public var `message`: String
        public var `session_id`: String
        public var `success`: Bool
        public var `user_id`: String
        public init(`cleanup_pending`: Bool? = nil, `cleared_message_ids`: [String]? = nil, `cleared_turn_ids`: [String]? = nil, `message`: String, `session_id`: String, `success`: Bool, `user_id`: String) {
            self.`cleanup_pending` = `cleanup_pending`
            self.`cleared_message_ids` = `cleared_message_ids`
            self.`cleared_turn_ids` = `cleared_turn_ids`
            self.`message` = `message`
            self.`session_id` = `session_id`
            self.`success` = `success`
            self.`user_id` = `user_id`
        }
    }
    public struct ClientEnvironment: Codable, Sendable, Equatable {
        public var `os`: String?
        public var `timezone`: String?
        public init(`os`: String? = nil, `timezone`: String? = nil) {
            self.`os` = `os`
            self.`timezone` = `timezone`
        }
    }
    public struct ContextUsageEvent: Codable, Sendable, Equatable {
        public var `contract_version`: Int64
        public var `data`: ProductContextUsage
        public var `epoch`: String
        public var `event_id`: String
        public var `event_type`: String
        public var `sequence`: Int64
        public var `server_id`: String
        public init(`contract_version`: Int64, `data`: ProductContextUsage, `epoch`: String, `event_id`: String, `event_type`: String, `sequence`: Int64, `server_id`: String) {
            self.`contract_version` = `contract_version`
            self.`data` = `data`
            self.`epoch` = `epoch`
            self.`event_id` = `event_id`
            self.`event_type` = `event_type`
            self.`sequence` = `sequence`
            self.`server_id` = `server_id`
        }
    }
    public typealias CreateSessionResponse = [String: JSONValue]
    public struct DeleteMessageResponse: Codable, Sendable, Equatable {
        public var `cleanup_pending`: Bool?
        public var `deleted_message_id`: String
        public var `session_id`: String
        public var `success`: Bool
        public var `user_id`: String
        public init(`cleanup_pending`: Bool? = nil, `deleted_message_id`: String, `session_id`: String, `success`: Bool, `user_id`: String) {
            self.`cleanup_pending` = `cleanup_pending`
            self.`deleted_message_id` = `deleted_message_id`
            self.`session_id` = `session_id`
            self.`success` = `success`
            self.`user_id` = `user_id`
        }
    }
    public struct DeleteSessionResponse: Codable, Sendable, Equatable {
        public var `cleanup_pending`: Bool?
        public var `deleted_session_id`: String
        public var `success`: Bool
        public var `user_id`: String
        public init(`cleanup_pending`: Bool? = nil, `deleted_session_id`: String, `success`: Bool, `user_id`: String) {
            self.`cleanup_pending` = `cleanup_pending`
            self.`deleted_session_id` = `deleted_session_id`
            self.`success` = `success`
            self.`user_id` = `user_id`
        }
    }
    public struct DetachSessionRunRequest: Codable, Sendable, Equatable {
        public var `reason`: String?
        public var `requested_by`: String?
        public var `turn_id`: String?
        public var `user_id`: String?
        public init(`reason`: String? = nil, `requested_by`: String? = nil, `turn_id`: String? = nil, `user_id`: String? = nil) {
            self.`reason` = `reason`
            self.`requested_by` = `requested_by`
            self.`turn_id` = `turn_id`
            self.`user_id` = `user_id`
        }
    }
    public struct EndpointRef: Codable, Sendable, Equatable {
        public var `connection_id`: String?
        public var `contribution_id`: String
        public var `device_id`: String?
        public var `target_id`: String
        public var `thread_id`: String?
        public init(`connection_id`: String? = nil, `contribution_id`: String, `device_id`: String? = nil, `target_id`: String, `thread_id`: String? = nil) {
            self.`connection_id` = `connection_id`
            self.`contribution_id` = `contribution_id`
            self.`device_id` = `device_id`
            self.`target_id` = `target_id`
            self.`thread_id` = `thread_id`
        }
    }
    public struct FirstContextStoryRequestModel: Codable, Sendable, Equatable {
        public var `question_id`: String
        public var `question_text`: String
        public init(`question_id`: String, `question_text`: String) {
            self.`question_id` = `question_id`
            self.`question_text` = `question_text`
        }
    }
    public struct GatewayAccessSession: Codable, Sendable, Equatable {
        public var `access_token`: String
        public var `client_id`: String
        public var `expires_at_ms`: Int64
        public var `server_id`: String
        public init(`access_token`: String, `client_id`: String, `expires_at_ms`: Int64, `server_id`: String) {
            self.`access_token` = `access_token`
            self.`client_id` = `client_id`
            self.`expires_at_ms` = `expires_at_ms`
            self.`server_id` = `server_id`
        }
    }
    public struct GatewayClientGrant: Codable, Sendable, Equatable {
        public var `client_credential`: String
        public var `client_id`: String
        public var `server_id`: String
        public init(`client_credential`: String, `client_id`: String, `server_id`: String) {
            self.`client_credential` = `client_credential`
            self.`client_id` = `client_id`
            self.`server_id` = `server_id`
        }
    }
    public struct GatewayMaintenanceStatus: Codable, Sendable, Equatable {
        public var `content_epoch`: String
        public var `data_epoch`: String
        public var `error`: JSONValue
        public var `kind`: JSONValue
        public var `operation_id`: JSONValue
        public var `phase`: String
        public var `result`: JSONValue
        public var `version`: Int64
        public init(`content_epoch`: String, `data_epoch`: String, `error`: JSONValue, `kind`: JSONValue, `operation_id`: JSONValue, `phase`: String, `result`: JSONValue, `version`: Int64) {
            self.`content_epoch` = `content_epoch`
            self.`data_epoch` = `data_epoch`
            self.`error` = `error`
            self.`kind` = `kind`
            self.`operation_id` = `operation_id`
            self.`phase` = `phase`
            self.`result` = `result`
            self.`version` = `version`
        }
    }
    public struct HTTPValidationError: Codable, Sendable, Equatable {
        public var `detail`: [ValidationError]?
        public init(`detail`: [ValidationError]? = nil) {
            self.`detail` = `detail`
        }
    }
    public struct HistoryPageResponse: Codable, Sendable, Equatable {
        public var `context_usage`: ChatContextUsageResponse?
        public var `count`: Int64
        public var `has_more`: Bool
        public var `history_version`: Int64
        public var `messages`: [ChatDisplayMessage]
        public var `next_before`: String?
        public var `not_modified`: Bool
        public var `revision`: String
        public var `session_id`: String
        public var `user_id`: String
        public init(`context_usage`: ChatContextUsageResponse? = nil, `count`: Int64, `has_more`: Bool, `history_version`: Int64, `messages`: [ChatDisplayMessage], `next_before`: String? = nil, `not_modified`: Bool, `revision`: String, `session_id`: String, `user_id`: String) {
            self.`context_usage` = `context_usage`
            self.`count` = `count`
            self.`has_more` = `has_more`
            self.`history_version` = `history_version`
            self.`messages` = `messages`
            self.`next_before` = `next_before`
            self.`not_modified` = `not_modified`
            self.`revision` = `revision`
            self.`session_id` = `session_id`
            self.`user_id` = `user_id`
        }
    }
    public struct InteractionEvent: Codable, Sendable, Equatable {
        public var `contract_version`: Int64
        public var `data`: ProductInteractionPointer
        public var `epoch`: String
        public var `event_id`: String
        public var `event_type`: String
        public var `sequence`: Int64
        public var `server_id`: String
        public init(`contract_version`: Int64, `data`: ProductInteractionPointer, `epoch`: String, `event_id`: String, `event_type`: String, `sequence`: Int64, `server_id`: String) {
            self.`contract_version` = `contract_version`
            self.`data` = `data`
            self.`epoch` = `epoch`
            self.`event_id` = `event_id`
            self.`event_type` = `event_type`
            self.`sequence` = `sequence`
            self.`server_id` = `server_id`
        }
    }
    public struct ItemDetail: Codable, Sendable, Equatable {
        public var `changes`: [TaskChange]
        public var `children`: [PersonalItem]
        public var `item`: PersonalItem
        public var `next_history_offset`: Int64?
        public init(`changes`: [TaskChange], `children`: [PersonalItem], `item`: PersonalItem, `next_history_offset`: Int64? = nil) {
            self.`changes` = `changes`
            self.`children` = `children`
            self.`item` = `item`
            self.`next_history_offset` = `next_history_offset`
        }
    }
    public struct ItemPage: Codable, Sendable, Equatable {
        public var `counts`: [String: Int64]
        public var `items`: [PersonalItem]
        public var `next_offset`: Int64?
        public var `total`: Int64
        public init(`counts`: [String: Int64], `items`: [PersonalItem], `next_offset`: Int64? = nil, `total`: Int64) {
            self.`counts` = `counts`
            self.`items` = `items`
            self.`next_offset` = `next_offset`
            self.`total` = `total`
        }
    }
    public struct ItemPatch: Codable, Sendable, Equatable {
        public var `body_md`: String?
        public var `defer_until`: String?
        public var `due`: String?
        public var `kind`: String?
        public var `parent_id`: String?
        public var `references`: [TaskReference]?
        public var `remind_at`: String?
        public var `status`: String?
        public var `timezone`: String?
        public var `title`: String?
        public init(`body_md`: String? = nil, `defer_until`: String? = nil, `due`: String? = nil, `kind`: String? = nil, `parent_id`: String? = nil, `references`: [TaskReference]? = nil, `remind_at`: String? = nil, `status`: String? = nil, `timezone`: String? = nil, `title`: String? = nil) {
            self.`body_md` = `body_md`
            self.`defer_until` = `defer_until`
            self.`due` = `due`
            self.`kind` = `kind`
            self.`parent_id` = `parent_id`
            self.`references` = `references`
            self.`remind_at` = `remind_at`
            self.`status` = `status`
            self.`timezone` = `timezone`
            self.`title` = `title`
        }
    }
    public typealias JsonValue = JSONValue
    public struct ListResponse: Codable, Sendable, Equatable {
        public var `items`: [NotificationItemModel]
        public var `total`: Int64
        public var `unread_count`: Int64
        public init(`items`: [NotificationItemModel], `total`: Int64, `unread_count`: Int64) {
            self.`items` = `items`
            self.`total` = `total`
            self.`unread_count` = `unread_count`
        }
    }
    public struct MarkReadRequest: Codable, Sendable, Equatable {
        public var `all`: Bool?
        public var `ids`: [Int64]?
        public init(`all`: Bool? = nil, `ids`: [Int64]? = nil) {
            self.`all` = `all`
            self.`ids` = `ids`
        }
    }
    public struct MessageHiddenEvent: Codable, Sendable, Equatable {
        public var `contract_version`: Int64
        public var `data`: ProductMessageHidden
        public var `epoch`: String
        public var `event_id`: String
        public var `event_type`: String
        public var `sequence`: Int64
        public var `server_id`: String
        public init(`contract_version`: Int64, `data`: ProductMessageHidden, `epoch`: String, `event_id`: String, `event_type`: String, `sequence`: Int64, `server_id`: String) {
            self.`contract_version` = `contract_version`
            self.`data` = `data`
            self.`epoch` = `epoch`
            self.`event_id` = `event_id`
            self.`event_type` = `event_type`
            self.`sequence` = `sequence`
            self.`server_id` = `server_id`
        }
    }
    public struct MessageLabelRequest: Codable, Sendable, Equatable {
        public var `applied_by`: String
        public var `created_at_ms`: Int64?
        public var `kind`: String
        public var `source`: String
        public var `text`: String
        public var `user_id`: String?
        public init(`applied_by`: String, `created_at_ms`: Int64? = nil, `kind`: String, `source`: String, `text`: String, `user_id`: String? = nil) {
            self.`applied_by` = `applied_by`
            self.`created_at_ms` = `created_at_ms`
            self.`kind` = `kind`
            self.`source` = `source`
            self.`text` = `text`
            self.`user_id` = `user_id`
        }
    }
    public struct MessageResponse: Codable, Sendable, Equatable {
        public var `data`: [String: JSONValue]?
        public var `message`: String
        public var `success`: Bool
        public init(`data`: [String: JSONValue]? = nil, `message`: String, `success`: Bool) {
            self.`data` = `data`
            self.`message` = `message`
            self.`success` = `success`
        }
    }
    public struct MessageUpsertEvent: Codable, Sendable, Equatable {
        public var `contract_version`: Int64
        public var `data`: ProductMessageUpsert
        public var `epoch`: String
        public var `event_id`: String
        public var `event_type`: String
        public var `sequence`: Int64
        public var `server_id`: String
        public init(`contract_version`: Int64, `data`: ProductMessageUpsert, `epoch`: String, `event_id`: String, `event_type`: String, `sequence`: Int64, `server_id`: String) {
            self.`contract_version` = `contract_version`
            self.`data` = `data`
            self.`epoch` = `epoch`
            self.`event_id` = `event_id`
            self.`event_type` = `event_type`
            self.`sequence` = `sequence`
            self.`server_id` = `server_id`
        }
    }
    public struct MutationResult: Codable, Sendable, Equatable {
        public var `deleted_ids`: [String]?
        public var `item`: PersonalItem?
        public var `reminders_pending`: Bool?
        public var `replayed`: Bool?
        public init(`deleted_ids`: [String]? = nil, `item`: PersonalItem? = nil, `reminders_pending`: Bool? = nil, `replayed`: Bool? = nil) {
            self.`deleted_ids` = `deleted_ids`
            self.`item` = `item`
            self.`reminders_pending` = `reminders_pending`
            self.`replayed` = `replayed`
        }
    }
    public struct NotificationEvent: Codable, Sendable, Equatable {
        public var `contract_version`: Int64
        public var `data`: ProductNotificationCount
        public var `epoch`: String
        public var `event_id`: String
        public var `event_type`: String
        public var `sequence`: Int64
        public var `server_id`: String
        public init(`contract_version`: Int64, `data`: ProductNotificationCount, `epoch`: String, `event_id`: String, `event_type`: String, `sequence`: Int64, `server_id`: String) {
            self.`contract_version` = `contract_version`
            self.`data` = `data`
            self.`epoch` = `epoch`
            self.`event_id` = `event_id`
            self.`event_type` = `event_type`
            self.`sequence` = `sequence`
            self.`server_id` = `server_id`
        }
    }
    public struct NotificationItemModel: Codable, Sendable, Equatable {
        public var `body`: String
        public var `created_at_ms`: Int64
        public var `dedupe_key`: String
        public var `id`: Int64
        public var `kind`: String
        public var `payload`: [String: JSONValue]
        public var `read_at_ms`: Int64?
        public var `status`: String
        public var `title`: String
        public init(`body`: String, `created_at_ms`: Int64, `dedupe_key`: String, `id`: Int64, `kind`: String, `payload`: [String: JSONValue], `read_at_ms`: Int64? = nil, `status`: String, `title`: String) {
            self.`body` = `body`
            self.`created_at_ms` = `created_at_ms`
            self.`dedupe_key` = `dedupe_key`
            self.`id` = `id`
            self.`kind` = `kind`
            self.`payload` = `payload`
            self.`read_at_ms` = `read_at_ms`
            self.`status` = `status`
            self.`title` = `title`
        }
    }
    public struct PairRequest: Codable, Sendable, Equatable {
        public var `name`: String
        public init(`name`: String) {
            self.`name` = `name`
        }
    }
    public struct PairResponse: Codable, Sendable, Equatable {
        public var `data`: GatewayClientGrant
        public var `success`: Bool
        public init(`data`: GatewayClientGrant, `success`: Bool) {
            self.`data` = `data`
            self.`success` = `success`
        }
    }
    public typealias PermissionsSnapshot = [String: JSONValue]
    public struct PersonalItem: Codable, Sendable, Equatable {
        public var `body_md`: String?
        public var `closed_at`: Double?
        public var `created_at`: Double
        public var `defer_until`: String?
        public var `due`: String?
        public var `id`: String
        public var `kind`: String?
        public var `origin`: String
        public var `parent_id`: String?
        public var `references`: [TaskReference]?
        public var `remind_at`: String?
        public var `reminder_delivered_revision`: Int64?
        public var `reminder_revision`: Int64?
        public var `reminder_synced_revision`: Int64?
        public var `status`: String?
        public var `timezone`: String?
        public var `title`: String
        public var `updated_at`: Double
        public var `user_id`: String
        public var `version`: Int64
        public init(`body_md`: String? = nil, `closed_at`: Double? = nil, `created_at`: Double, `defer_until`: String? = nil, `due`: String? = nil, `id`: String, `kind`: String? = nil, `origin`: String, `parent_id`: String? = nil, `references`: [TaskReference]? = nil, `remind_at`: String? = nil, `reminder_delivered_revision`: Int64? = nil, `reminder_revision`: Int64? = nil, `reminder_synced_revision`: Int64? = nil, `status`: String? = nil, `timezone`: String? = nil, `title`: String, `updated_at`: Double, `user_id`: String, `version`: Int64) {
            self.`body_md` = `body_md`
            self.`closed_at` = `closed_at`
            self.`created_at` = `created_at`
            self.`defer_until` = `defer_until`
            self.`due` = `due`
            self.`id` = `id`
            self.`kind` = `kind`
            self.`origin` = `origin`
            self.`parent_id` = `parent_id`
            self.`references` = `references`
            self.`remind_at` = `remind_at`
            self.`reminder_delivered_revision` = `reminder_delivered_revision`
            self.`reminder_revision` = `reminder_revision`
            self.`reminder_synced_revision` = `reminder_synced_revision`
            self.`status` = `status`
            self.`timezone` = `timezone`
            self.`title` = `title`
            self.`updated_at` = `updated_at`
            self.`user_id` = `user_id`
            self.`version` = `version`
        }
    }
    public struct ProductContextUsage: Codable, Sendable, Equatable {
        public var `input_capacity`: Int64
        public var `measurement`: String?
        public var `model_id`: String?
        public var `model_provider`: String?
        public var `session_id`: String
        public var `threshold`: Double
        public var `timestamp`: Double
        public var `turn_id`: String
        public var `updated_at_ms`: Int64?
        public var `used_tokens`: Int64
        public var `user_id`: String
        public var `window_size`: Int64
        public init(`input_capacity`: Int64, `measurement`: String? = nil, `model_id`: String? = nil, `model_provider`: String? = nil, `session_id`: String, `threshold`: Double, `timestamp`: Double, `turn_id`: String, `updated_at_ms`: Int64? = nil, `used_tokens`: Int64, `user_id`: String, `window_size`: Int64) {
            self.`input_capacity` = `input_capacity`
            self.`measurement` = `measurement`
            self.`model_id` = `model_id`
            self.`model_provider` = `model_provider`
            self.`session_id` = `session_id`
            self.`threshold` = `threshold`
            self.`timestamp` = `timestamp`
            self.`turn_id` = `turn_id`
            self.`updated_at_ms` = `updated_at_ms`
            self.`used_tokens` = `used_tokens`
            self.`user_id` = `user_id`
            self.`window_size` = `window_size`
        }
    }
    public typealias ProductEvent = JSONValue
    public struct ProductInteractionPointer: Codable, Sendable, Equatable {
        public var `request_id`: String?
        public var `run_id`: String?
        public var `session_id`: String
        public var `user_id`: String?
        public init(`request_id`: String? = nil, `run_id`: String? = nil, `session_id`: String, `user_id`: String? = nil) {
            self.`request_id` = `request_id`
            self.`run_id` = `run_id`
            self.`session_id` = `session_id`
            self.`user_id` = `user_id`
        }
    }
    public struct ProductMessageHidden: Codable, Sendable, Equatable {
        public var `message_id`: String
        public var `session_id`: String
        public var `session_summary`: ChatSessionSummary?
        public var `user_id`: String
        public init(`message_id`: String, `session_id`: String, `session_summary`: ChatSessionSummary? = nil, `user_id`: String) {
            self.`message_id` = `message_id`
            self.`session_id` = `session_id`
            self.`session_summary` = `session_summary`
            self.`user_id` = `user_id`
        }
    }
    public struct ProductMessageUpsert: Codable, Sendable, Equatable {
        public var `message`: ChatDisplayMessage
        public var `message_id`: String
        public var `session_id`: String
        public var `session_summary`: ChatSessionSummary?
        public var `user_id`: String
        public init(`message`: ChatDisplayMessage, `message_id`: String, `session_id`: String, `session_summary`: ChatSessionSummary? = nil, `user_id`: String) {
            self.`message` = `message`
            self.`message_id` = `message_id`
            self.`session_id` = `session_id`
            self.`session_summary` = `session_summary`
            self.`user_id` = `user_id`
        }
    }
    public struct ProductNotificationCount: Codable, Sendable, Equatable {
        public var `unread_count`: Int64
        public init(`unread_count`: Int64) {
            self.`unread_count` = `unread_count`
        }
    }
    public struct ProductResourceChange: Codable, Sendable, Equatable {
        public var `resource`: String
        public init(`resource`: String) {
            self.`resource` = `resource`
        }
    }
    public struct ProductResponseDisplay: Codable, Sendable, Equatable {
        public var `attachments`: [[String: JsonValue]]?
        public var `content`: String
        public var `is_final`: Bool
        public var `message_id`: String?
        public var `message_kind`: String?
        public var `message_payload`: [String: JsonValue]?
        public var `persona_id`: String?
        public var `reply_to_message_id`: String?
        public var `session_id`: String
        public var `timestamp`: Double
        public var `trace_available`: Bool?
        public var `turn_id`: String?
        public var `user_id`: String
        public var `ux_plan`: [String: JsonValue]?
        public init(`attachments`: [[String: JsonValue]]? = nil, `content`: String, `is_final`: Bool, `message_id`: String? = nil, `message_kind`: String? = nil, `message_payload`: [String: JsonValue]? = nil, `persona_id`: String? = nil, `reply_to_message_id`: String? = nil, `session_id`: String, `timestamp`: Double, `trace_available`: Bool? = nil, `turn_id`: String? = nil, `user_id`: String, `ux_plan`: [String: JsonValue]? = nil) {
            self.`attachments` = `attachments`
            self.`content` = `content`
            self.`is_final` = `is_final`
            self.`message_id` = `message_id`
            self.`message_kind` = `message_kind`
            self.`message_payload` = `message_payload`
            self.`persona_id` = `persona_id`
            self.`reply_to_message_id` = `reply_to_message_id`
            self.`session_id` = `session_id`
            self.`timestamp` = `timestamp`
            self.`trace_available` = `trace_available`
            self.`turn_id` = `turn_id`
            self.`user_id` = `user_id`
            self.`ux_plan` = `ux_plan`
        }
    }
    public struct ProductResponsePreview: Codable, Sendable, Equatable {
        public var `event`: ProductTextPreview
        public var `is_final`: Bool
        public var `persona_id`: String?
        public var `seq`: Int64
        public var `session_id`: String
        public var `timestamp`: Double
        public var `turn_id`: String
        public var `user_id`: String
        public init(`event`: ProductTextPreview, `is_final`: Bool, `persona_id`: String? = nil, `seq`: Int64, `session_id`: String, `timestamp`: Double, `turn_id`: String, `user_id`: String) {
            self.`event` = `event`
            self.`is_final` = `is_final`
            self.`persona_id` = `persona_id`
            self.`seq` = `seq`
            self.`session_id` = `session_id`
            self.`timestamp` = `timestamp`
            self.`turn_id` = `turn_id`
            self.`user_id` = `user_id`
        }
    }
    public struct ProductResyncRequired: Codable, Sendable, Equatable {
        public var `reason`: String
        public init(`reason`: String) {
            self.`reason` = `reason`
        }
    }
    public struct ProductTextPreview: Codable, Sendable, Equatable {
        public var `error_kind`: String?
        public var `error_message`: String?
        public var `kind`: String
        public var `step_label`: String?
        public var `text`: String?
        public init(`error_kind`: String? = nil, `error_message`: String? = nil, `kind`: String, `step_label`: String? = nil, `text`: String? = nil) {
            self.`error_kind` = `error_kind`
            self.`error_message` = `error_message`
            self.`kind` = `kind`
            self.`step_label` = `step_label`
            self.`text` = `text`
        }
    }
    public struct ProductTurnControl: Codable, Sendable, Equatable {
        public var `can_cancel`: Bool
        public var `label`: String?
        public var `run_id`: String?
        public var `session_id`: String
        public var `state`: String
        public var `timestamp`: Double
        public var `turn_id`: String
        public var `user_id`: String
        public init(`can_cancel`: Bool, `label`: String? = nil, `run_id`: String? = nil, `session_id`: String, `state`: String, `timestamp`: Double, `turn_id`: String, `user_id`: String) {
            self.`can_cancel` = `can_cancel`
            self.`label` = `label`
            self.`run_id` = `run_id`
            self.`session_id` = `session_id`
            self.`state` = `state`
            self.`timestamp` = `timestamp`
            self.`turn_id` = `turn_id`
            self.`user_id` = `user_id`
        }
    }
    public struct ProductTurnPresentation: Codable, Sendable, Equatable {
        public var `message_id`: String?
        public var `message_kind`: String?
        public var `session_id`: String
        public var `timestamp`: Double
        public var `turn_id`: String
        public var `user_id`: String
        public var `ux_plan`: [String: JsonValue]
        public init(`message_id`: String? = nil, `message_kind`: String? = nil, `session_id`: String, `timestamp`: Double, `turn_id`: String, `user_id`: String, `ux_plan`: [String: JsonValue]) {
            self.`message_id` = `message_id`
            self.`message_kind` = `message_kind`
            self.`session_id` = `session_id`
            self.`timestamp` = `timestamp`
            self.`turn_id` = `turn_id`
            self.`user_id` = `user_id`
            self.`ux_plan` = `ux_plan`
        }
    }
    public typealias RecallFeedbackKind = String
    public struct RecallFeedbackRequestModel: Codable, Sendable, Equatable {
        public var `finding_ref`: String?
        public var `kind`: RecallFeedbackKind
        public var `target_message_id`: String
        public init(`finding_ref`: String? = nil, `kind`: RecallFeedbackKind, `target_message_id`: String) {
            self.`finding_ref` = `finding_ref`
            self.`kind` = `kind`
            self.`target_message_id` = `target_message_id`
        }
    }
    public struct RenameSessionRequest: Codable, Sendable, Equatable {
        public var `title`: String
        public var `user_id`: String?
        public init(`title`: String, `user_id`: String? = nil) {
            self.`title` = `title`
            self.`user_id` = `user_id`
        }
    }
    public struct ResolveConflictRequest: Codable, Sendable, Equatable {
        public var `action`: String
        public init(`action`: String) {
            self.`action` = `action`
        }
    }
    public struct ResolveConflictResponse: Codable, Sendable, Equatable {
        public var `action`: String
        public var `resolved`: Bool
        public var `status`: String
        public init(`action`: String, `resolved`: Bool, `status`: String) {
            self.`action` = `action`
            self.`resolved` = `resolved`
            self.`status` = `status`
        }
    }
    public struct ResourceChangeEvent: Codable, Sendable, Equatable {
        public var `contract_version`: Int64
        public var `data`: ProductResourceChange
        public var `epoch`: String
        public var `event_id`: String
        public var `event_type`: String
        public var `sequence`: Int64
        public var `server_id`: String
        public init(`contract_version`: Int64, `data`: ProductResourceChange, `epoch`: String, `event_id`: String, `event_type`: String, `sequence`: Int64, `server_id`: String) {
            self.`contract_version` = `contract_version`
            self.`data` = `data`
            self.`epoch` = `epoch`
            self.`event_id` = `event_id`
            self.`event_type` = `event_type`
            self.`sequence` = `sequence`
            self.`server_id` = `server_id`
        }
    }
    public struct ResponseDisplayEvent: Codable, Sendable, Equatable {
        public var `contract_version`: Int64
        public var `data`: ProductResponseDisplay
        public var `epoch`: String
        public var `event_id`: String
        public var `event_type`: String
        public var `sequence`: Int64
        public var `server_id`: String
        public init(`contract_version`: Int64, `data`: ProductResponseDisplay, `epoch`: String, `event_id`: String, `event_type`: String, `sequence`: Int64, `server_id`: String) {
            self.`contract_version` = `contract_version`
            self.`data` = `data`
            self.`epoch` = `epoch`
            self.`event_id` = `event_id`
            self.`event_type` = `event_type`
            self.`sequence` = `sequence`
            self.`server_id` = `server_id`
        }
    }
    public struct ResponsePreviewEvent: Codable, Sendable, Equatable {
        public var `contract_version`: Int64
        public var `data`: ProductResponsePreview
        public var `epoch`: String
        public var `event_id`: String
        public var `event_type`: String
        public var `sequence`: Int64
        public var `server_id`: String
        public init(`contract_version`: Int64, `data`: ProductResponsePreview, `epoch`: String, `event_id`: String, `event_type`: String, `sequence`: Int64, `server_id`: String) {
            self.`contract_version` = `contract_version`
            self.`data` = `data`
            self.`epoch` = `epoch`
            self.`event_id` = `event_id`
            self.`event_type` = `event_type`
            self.`sequence` = `sequence`
            self.`server_id` = `server_id`
        }
    }
    public struct ResyncEvent: Codable, Sendable, Equatable {
        public var `contract_version`: Int64
        public var `data`: ProductResyncRequired
        public var `epoch`: String
        public var `event_id`: String
        public var `event_type`: String
        public var `sequence`: Int64
        public var `server_id`: String
        public init(`contract_version`: Int64, `data`: ProductResyncRequired, `epoch`: String, `event_id`: String, `event_type`: String, `sequence`: Int64, `server_id`: String) {
            self.`contract_version` = `contract_version`
            self.`data` = `data`
            self.`epoch` = `epoch`
            self.`event_id` = `event_id`
            self.`event_type` = `event_type`
            self.`sequence` = `sequence`
            self.`server_id` = `server_id`
        }
    }
    public struct SendConfirmation: Codable, Sendable, Equatable {
        public var `identity`: String
        public var `safe_to_retry`: Bool
        public var `session_id`: String
        public var `status`: String
        public init(`identity`: String, `safe_to_retry`: Bool, `session_id`: String, `status`: String) {
            self.`identity` = `identity`
            self.`safe_to_retry` = `safe_to_retry`
            self.`session_id` = `session_id`
            self.`status` = `status`
        }
    }
    public typealias SendConfirmationRequest = JSONValue
    public struct ServerInfoResponse: Codable, Sendable, Equatable {
        public var `data`: ServerInfoResponse_data
        public var `success`: Bool
        public init(`data`: ServerInfoResponse_data, `success`: Bool) {
            self.`data` = `data`
            self.`success` = `success`
        }
    }
    public struct SessionPageResponse: Codable, Sendable, Equatable {
        public var `count`: Int64
        public var `has_more`: Bool
        public var `next_before`: String?
        public var `not_modified`: Bool
        public var `revision`: String
        public var `sessions`: [ChatSessionSummary]
        public var `user_id`: String
        public init(`count`: Int64, `has_more`: Bool, `next_before`: String? = nil, `not_modified`: Bool, `revision`: String, `sessions`: [ChatSessionSummary], `user_id`: String) {
            self.`count` = `count`
            self.`has_more` = `has_more`
            self.`next_before` = `next_before`
            self.`not_modified` = `not_modified`
            self.`revision` = `revision`
            self.`sessions` = `sessions`
            self.`user_id` = `user_id`
        }
    }
    public struct SkillInvocationRequestModel: Codable, Sendable, Equatable {
        public var `arguments`: [String]?
        public var `name`: String
        public init(`arguments`: [String]? = nil, `name`: String) {
            self.`arguments` = `arguments`
            self.`name` = `name`
        }
    }
    public struct TaskChange: Codable, Sendable, Equatable {
        public var `action`: String
        public var `actor`: String
        public var `changes`: [String: JSONValue]
        public var `created_at`: Double
        public var `id`: Int64
        public var `item_id`: String
        public var `note`: String
        public var `references`: [TaskReference]
        public var `version`: Int64
        public init(`action`: String, `actor`: String, `changes`: [String: JSONValue], `created_at`: Double, `id`: Int64, `item_id`: String, `note`: String, `references`: [TaskReference], `version`: Int64) {
            self.`action` = `action`
            self.`actor` = `actor`
            self.`changes` = `changes`
            self.`created_at` = `created_at`
            self.`id` = `id`
            self.`item_id` = `item_id`
            self.`note` = `note`
            self.`references` = `references`
            self.`version` = `version`
        }
    }
    public struct TaskMutation: Codable, Sendable, Equatable {
        public var `action`: String
        public var `cascade`: Bool?
        public var `expected_version`: Int64?
        public var `fields`: ItemPatch?
        public var `item_id`: String?
        public var `note`: String?
        public var `request_id`: String
        public init(`action`: String, `cascade`: Bool? = nil, `expected_version`: Int64? = nil, `fields`: ItemPatch? = nil, `item_id`: String? = nil, `note`: String? = nil, `request_id`: String) {
            self.`action` = `action`
            self.`cascade` = `cascade`
            self.`expected_version` = `expected_version`
            self.`fields` = `fields`
            self.`item_id` = `item_id`
            self.`note` = `note`
            self.`request_id` = `request_id`
        }
    }
    public struct TaskReference: Codable, Sendable, Equatable {
        public var `id`: String
        public var `kind`: String
        public var `label`: String?
        public var `session_id`: String?
        public init(`id`: String, `kind`: String, `label`: String? = nil, `session_id`: String? = nil) {
            self.`id` = `id`
            self.`kind` = `kind`
            self.`label` = `label`
            self.`session_id` = `session_id`
        }
    }
    public struct TurnConfirmationRequest: Codable, Sendable, Equatable {
        public var `kind`: String
        public var `session_id`: String
        public var `turn_id`: String
        public init(`kind`: String, `session_id`: String, `turn_id`: String) {
            self.`kind` = `kind`
            self.`session_id` = `session_id`
            self.`turn_id` = `turn_id`
        }
    }
    public struct TurnControlEvent: Codable, Sendable, Equatable {
        public var `contract_version`: Int64
        public var `data`: ProductTurnControl
        public var `epoch`: String
        public var `event_id`: String
        public var `event_type`: String
        public var `sequence`: Int64
        public var `server_id`: String
        public init(`contract_version`: Int64, `data`: ProductTurnControl, `epoch`: String, `event_id`: String, `event_type`: String, `sequence`: Int64, `server_id`: String) {
            self.`contract_version` = `contract_version`
            self.`data` = `data`
            self.`epoch` = `epoch`
            self.`event_id` = `event_id`
            self.`event_type` = `event_type`
            self.`sequence` = `sequence`
            self.`server_id` = `server_id`
        }
    }
    public struct TurnPresentationEvent: Codable, Sendable, Equatable {
        public var `contract_version`: Int64
        public var `data`: ProductTurnPresentation
        public var `epoch`: String
        public var `event_id`: String
        public var `event_type`: String
        public var `sequence`: Int64
        public var `server_id`: String
        public init(`contract_version`: Int64, `data`: ProductTurnPresentation, `epoch`: String, `event_id`: String, `event_type`: String, `sequence`: Int64, `server_id`: String) {
            self.`contract_version` = `contract_version`
            self.`data` = `data`
            self.`epoch` = `epoch`
            self.`event_id` = `event_id`
            self.`event_type` = `event_type`
            self.`sequence` = `sequence`
            self.`server_id` = `server_id`
        }
    }
    public struct TurnSnapshot: Codable, Sendable, Equatable {
        public var `acceptance`: String
        public var `can_resubmit`: Bool
        public var `presentation_ends_at_ms`: Int64?
        public var `response_complete`: Bool
        public var `revision`: String
        public var `session_id`: String
        public var `state`: String?
        public var `terminal`: Bool
        public var `turn_id`: String
        public init(`acceptance`: String, `can_resubmit`: Bool, `presentation_ends_at_ms`: Int64? = nil, `response_complete`: Bool, `revision`: String, `session_id`: String, `state`: String? = nil, `terminal`: Bool, `turn_id`: String) {
            self.`acceptance` = `acceptance`
            self.`can_resubmit` = `can_resubmit`
            self.`presentation_ends_at_ms` = `presentation_ends_at_ms`
            self.`response_complete` = `response_complete`
            self.`revision` = `revision`
            self.`session_id` = `session_id`
            self.`state` = `state`
            self.`terminal` = `terminal`
            self.`turn_id` = `turn_id`
        }
    }
    public typealias UploadResponse = [String: JSONValue]
    public struct UserMessageRequest: Codable, Sendable, Equatable {
        public var `attachments`: [[String: JSONValue]]?
        public var `client_environment`: ClientEnvironment?
        public var `client_turn_id`: String?
        public var `delivery_targets`: [EndpointRef]?
        public var `first_context`: FirstContextStoryRequestModel?
        public var `interaction_kind`: String?
        public var `message`: String?
        public var `metadata`: [String: JSONValue]?
        public var `personal_task_id`: String?
        public var `reasoning_preference`: String?
        public var `recall_feedback`: RecallFeedbackRequestModel?
        public var `reply_to_message_id`: String?
        public var `run_disposition`: String?
        public var `session_id`: String?
        public var `skill_invocation`: SkillInvocationRequestModel?
        public var `user_id`: String?
        public var `workspace_path`: String?
        public init(`attachments`: [[String: JSONValue]]? = nil, `client_environment`: ClientEnvironment? = nil, `client_turn_id`: String? = nil, `delivery_targets`: [EndpointRef]? = nil, `first_context`: FirstContextStoryRequestModel? = nil, `interaction_kind`: String? = nil, `message`: String? = nil, `metadata`: [String: JSONValue]? = nil, `personal_task_id`: String? = nil, `reasoning_preference`: String? = nil, `recall_feedback`: RecallFeedbackRequestModel? = nil, `reply_to_message_id`: String? = nil, `run_disposition`: String? = nil, `session_id`: String? = nil, `skill_invocation`: SkillInvocationRequestModel? = nil, `user_id`: String? = nil, `workspace_path`: String? = nil) {
            self.`attachments` = `attachments`
            self.`client_environment` = `client_environment`
            self.`client_turn_id` = `client_turn_id`
            self.`delivery_targets` = `delivery_targets`
            self.`first_context` = `first_context`
            self.`interaction_kind` = `interaction_kind`
            self.`message` = `message`
            self.`metadata` = `metadata`
            self.`personal_task_id` = `personal_task_id`
            self.`reasoning_preference` = `reasoning_preference`
            self.`recall_feedback` = `recall_feedback`
            self.`reply_to_message_id` = `reply_to_message_id`
            self.`run_disposition` = `run_disposition`
            self.`session_id` = `session_id`
            self.`skill_invocation` = `skill_invocation`
            self.`user_id` = `user_id`
            self.`workspace_path` = `workspace_path`
        }
    }
    public struct ValidationError: Codable, Sendable, Equatable {
        public var `ctx`: [String: JSONValue]?
        public var `input`: JSONValue?
        public var `loc`: [JSONValue]
        public var `msg`: String
        public var `type`: String
        public init(`ctx`: [String: JSONValue]? = nil, `input`: JSONValue? = nil, `loc`: [JSONValue], `msg`: String, `type`: String) {
            self.`ctx` = `ctx`
            self.`input` = `input`
            self.`loc` = `loc`
            self.`msg` = `msg`
            self.`type` = `type`
        }
    }
    public struct AskRespondRequest: Codable, Sendable, Equatable {
        public var `answer`: String
        public init(`answer`: String) {
            self.`answer` = `answer`
        }
    }
    public struct PermissionRespondRequest: Codable, Sendable, Equatable {
        public var `outcome`: String
        public var `pattern`: String?
        public var `reason`: String?
        public var `scope`: String?
        public init(`outcome`: String, `pattern`: String? = nil, `reason`: String? = nil, `scope`: String? = nil) {
            self.`outcome` = `outcome`
            self.`pattern` = `pattern`
            self.`reason` = `reason`
            self.`scope` = `scope`
        }
    }
    public struct ServerInfoResponse_data: Codable, Sendable, Equatable {
        public var `client_contract`: ServerInfoResponse_data_client_contract
        public var `events`: ServerInfoResponse_data_events
        public var `maintenance`: GatewayMaintenanceStatus?
        public var `plugin_execution`: String
        public var `protocol_version`: Int64
        public var `server_id`: String
        public var `service_ready`: Bool
        public var `supervisor`: [String: JSONValue]
        public init(`client_contract`: ServerInfoResponse_data_client_contract, `events`: ServerInfoResponse_data_events, `maintenance`: GatewayMaintenanceStatus? = nil, `plugin_execution`: String, `protocol_version`: Int64, `server_id`: String, `service_ready`: Bool, `supervisor`: [String: JSONValue]) {
            self.`client_contract` = `client_contract`
            self.`events` = `events`
            self.`maintenance` = `maintenance`
            self.`plugin_execution` = `plugin_execution`
            self.`protocol_version` = `protocol_version`
            self.`server_id` = `server_id`
            self.`service_ready` = `service_ready`
            self.`supervisor` = `supervisor`
        }
    }
    public struct ServerInfoResponse_data_client_contract: Codable, Sendable, Equatable {
        public var `diagnostic_events`: String
        public var `product_events`: String
        public var `schema`: String
        public var `version`: Int64
        public init(`diagnostic_events`: String, `product_events`: String, `schema`: String, `version`: Int64) {
            self.`diagnostic_events` = `diagnostic_events`
            self.`product_events` = `product_events`
            self.`schema` = `schema`
            self.`version` = `version`
        }
    }
    public struct ServerInfoResponse_data_events: Codable, Sendable, Equatable {
        public var `epoch`: String
        public var `sequence`: Int64
        public init(`epoch`: String, `sequence`: Int64) {
            self.`epoch` = `epoch`
            self.`sequence` = `sequence`
        }
    }
}
