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
    public struct ActivationFirstContextSpec: Codable, Sendable, Equatable {
        public var `max_items_per_sync`: Int64?
        public var `settings_overrides`: [String: JSONValue]?
        public init(`max_items_per_sync`: Int64? = nil, `settings_overrides`: [String: JSONValue]? = nil) {
            self.`max_items_per_sync` = `max_items_per_sync`
            self.`settings_overrides` = `settings_overrides`
        }
    }
    public struct ActivationFlowResponse: Codable, Sendable, Equatable {
        public var `authorize_on_confirm`: Bool?
        public var `cancel_label`: String?
        public var `cancel_label_translated`: String?
        public var `configured_key`: String
        public var `confirm_label`: String?
        public var `confirm_label_translated`: String?
        public var `description`: String?
        public var `description_translated`: String?
        public var `enabled_key`: String
        public var `fields`: [ExtensionFieldResponse]?
        public var `first_context`: ActivationFirstContextSpec?
        public var `title`: String
        public var `title_translated`: String?
        public init(`authorize_on_confirm`: Bool? = nil, `cancel_label`: String? = nil, `cancel_label_translated`: String? = nil, `configured_key`: String, `confirm_label`: String? = nil, `confirm_label_translated`: String? = nil, `description`: String? = nil, `description_translated`: String? = nil, `enabled_key`: String, `fields`: [ExtensionFieldResponse]? = nil, `first_context`: ActivationFirstContextSpec? = nil, `title`: String, `title_translated`: String? = nil) {
            self.`authorize_on_confirm` = `authorize_on_confirm`
            self.`cancel_label` = `cancel_label`
            self.`cancel_label_translated` = `cancel_label_translated`
            self.`configured_key` = `configured_key`
            self.`confirm_label` = `confirm_label`
            self.`confirm_label_translated` = `confirm_label_translated`
            self.`description` = `description`
            self.`description_translated` = `description_translated`
            self.`enabled_key` = `enabled_key`
            self.`fields` = `fields`
            self.`first_context` = `first_context`
            self.`title` = `title`
            self.`title_translated` = `title_translated`
        }
    }
    public struct ActivationFlowSpec: Codable, Sendable, Equatable {
        public var `authorize_on_confirm`: Bool?
        public var `cancel_label`: String?
        public var `configured_key`: String
        public var `confirm_label`: String?
        public var `description`: String?
        public var `enabled_key`: String
        public var `fields`: [ExtensionFieldSpec]?
        public var `first_context`: ActivationFirstContextSpec?
        public var `title`: String
        public init(`authorize_on_confirm`: Bool? = nil, `cancel_label`: String? = nil, `configured_key`: String, `confirm_label`: String? = nil, `description`: String? = nil, `enabled_key`: String, `fields`: [ExtensionFieldSpec]? = nil, `first_context`: ActivationFirstContextSpec? = nil, `title`: String) {
            self.`authorize_on_confirm` = `authorize_on_confirm`
            self.`cancel_label` = `cancel_label`
            self.`configured_key` = `configured_key`
            self.`confirm_label` = `confirm_label`
            self.`description` = `description`
            self.`enabled_key` = `enabled_key`
            self.`fields` = `fields`
            self.`first_context` = `first_context`
            self.`title` = `title`
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
    public struct BackgroundEvent: Codable, Sendable, Equatable {
        public var `event_id`: String
        public var `occurred_at_ms`: Int64
        public var `payload`: JSONValue
        public var `sequence`: Int64
        public var `stream`: String
        public init(`event_id`: String, `occurred_at_ms`: Int64, `payload`: JSONValue, `sequence`: Int64, `stream`: String) {
            self.`event_id` = `event_id`
            self.`occurred_at_ms` = `occurred_at_ms`
            self.`payload` = `payload`
            self.`sequence` = `sequence`
            self.`stream` = `stream`
        }
    }
    public struct Body_create_plugin_install_candidate_api_plugins_install_candidates_post: Codable, Sendable, Equatable {
        public var `file`: String
        public init(`file`: String) {
            self.`file` = `file`
        }
    }
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
    public struct CapabilityReadiness: Codable, Sendable, Equatable {
        public var `capability_id`: String
        public var `connection_id`: String
        public var `message`: String?
        public var `reason_code`: String?
        public var `status`: ConnectionStatus
        public init(`capability_id`: String, `connection_id`: String, `message`: String? = nil, `reason_code`: String? = nil, `status`: ConnectionStatus) {
            self.`capability_id` = `capability_id`
            self.`connection_id` = `connection_id`
            self.`message` = `message`
            self.`reason_code` = `reason_code`
            self.`status` = `status`
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
    public struct CollectionCapability: Codable, Sendable, Equatable {
        public var `capability_id`: String
        public var `direction`: String?
        public var `payload_schema`: [String: JsonValue]
        public var `protocol`: String
        public var `schema_id`: String
        public var `schema_version`: Int64
        public var `supports_resources`: Bool?
        public init(`capability_id`: String, `direction`: String? = nil, `payload_schema`: [String: JsonValue], `protocol`: String, `schema_id`: String, `schema_version`: Int64, `supports_resources`: Bool? = nil) {
            self.`capability_id` = `capability_id`
            self.`direction` = `direction`
            self.`payload_schema` = `payload_schema`
            self.`protocol` = `protocol`
            self.`schema_id` = `schema_id`
            self.`schema_version` = `schema_version`
            self.`supports_resources` = `supports_resources`
        }
    }
    public struct CollectorClaim: Codable, Sendable, Equatable {
        public var `capability_id`: String
        public var `connection_epoch`: String
        public var `protocol`: String
        public var `schema_id`: String
        public var `schema_version`: Int64
        public init(`capability_id`: String, `connection_epoch`: String, `protocol`: String, `schema_id`: String, `schema_version`: Int64) {
            self.`capability_id` = `capability_id`
            self.`connection_epoch` = `connection_epoch`
            self.`protocol` = `protocol`
            self.`schema_id` = `schema_id`
            self.`schema_version` = `schema_version`
        }
    }
    public struct CollectorRelease: Codable, Sendable, Equatable {
        public var `source_type`: String
        public init(`source_type`: String) {
            self.`source_type` = `source_type`
        }
    }
    public struct CollectorScope: Codable, Sendable, Equatable {
        public var `capability`: CollectionCapability
        public var `claimed_by`: String?
        public var `connection_epoch`: String
        public var `connection_id`: String
        public var `source_type`: String
        public init(`capability`: CollectionCapability, `claimed_by`: String? = nil, `connection_epoch`: String, `connection_id`: String, `source_type`: String) {
            self.`capability` = `capability`
            self.`claimed_by` = `claimed_by`
            self.`connection_epoch` = `connection_epoch`
            self.`connection_id` = `connection_id`
            self.`source_type` = `source_type`
        }
    }
    public struct ConnectionCreateRequest: Codable, Sendable, Equatable {
        public var `credentials`: [String: String]?
        public var `display_name`: String
        public var `enabled`: Bool?
        public var `settings`: [String: JsonValue]?
        public init(`credentials`: [String: String]? = nil, `display_name`: String, `enabled`: Bool? = nil, `settings`: [String: JsonValue]? = nil) {
            self.`credentials` = `credentials`
            self.`display_name` = `display_name`
            self.`enabled` = `enabled`
            self.`settings` = `settings`
        }
    }
    public struct ConnectionRevisionRequest: Codable, Sendable, Equatable {
        public var `expected_revision`: Int64
        public init(`expected_revision`: Int64) {
            self.`expected_revision` = `expected_revision`
        }
    }
    public typealias ConnectionStatus = String
    public struct ConnectionUpdateRequest: Codable, Sendable, Equatable {
        public var `credential_refs`: [String: String]?
        public var `credentials`: [String: String?]?
        public var `display_name`: String?
        public var `enabled`: Bool?
        public var `expected_revision`: Int64
        public var `settings`: [String: JsonValue]?
        public init(`credential_refs`: [String: String]? = nil, `credentials`: [String: String?]? = nil, `display_name`: String? = nil, `enabled`: Bool? = nil, `expected_revision`: Int64, `settings`: [String: JsonValue]? = nil) {
            self.`credential_refs` = `credential_refs`
            self.`credentials` = `credentials`
            self.`display_name` = `display_name`
            self.`enabled` = `enabled`
            self.`expected_revision` = `expected_revision`
            self.`settings` = `settings`
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
    public typealias ContributionType = String
    public typealias CreateSessionResponse = [String: JSONValue]
    public struct DeleteL1EventResponse: Codable, Sendable, Equatable {
        public var `deleted`: Bool
        public var `deletion_scope`: String
        public var `event_id`: String
        public init(`deleted`: Bool, `deletion_scope`: String, `event_id`: String) {
            self.`deleted` = `deleted`
            self.`deletion_scope` = `deletion_scope`
            self.`event_id` = `event_id`
        }
    }
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
    public struct DeliveryBatch: Codable, Sendable, Equatable {
        public var `data_epoch`: String
        public var `events`: [BackgroundEvent]
        public var `producer_id`: String
        public var `server_id`: String
        public init(`data_epoch`: String, `events`: [BackgroundEvent], `producer_id`: String, `server_id`: String) {
            self.`data_epoch` = `data_epoch`
            self.`events` = `events`
            self.`producer_id` = `producer_id`
            self.`server_id` = `server_id`
        }
    }
    public struct DeliveryReceipt: Codable, Sendable, Equatable {
        public var `data_epoch`: String
        public var `receipts`: [EventReceipt]
        public var `server_id`: String
        public init(`data_epoch`: String, `receipts`: [EventReceipt], `server_id`: String) {
            self.`data_epoch` = `data_epoch`
            self.`receipts` = `receipts`
            self.`server_id` = `server_id`
        }
    }
    public struct DeliverySelection: Codable, Sendable, Equatable {
        public var `connection_id`: String?
        public var `producer_id`: String?
        public var `stream`: String?
        public init(`connection_id`: String? = nil, `producer_id`: String? = nil, `stream`: String? = nil) {
            self.`connection_id` = `connection_id`
            self.`producer_id` = `producer_id`
            self.`stream` = `stream`
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
    public struct DeviceCollectorSpec: Codable, Sendable, Equatable {
        public var `capability_id`: String
        public var `platforms`: [String]
        public var `protocol`: String
        public var `schema_id`: String
        public var `schema_version`: Int64
        public var `source_type`: String
        public init(`capability_id`: String, `platforms`: [String], `protocol`: String, `schema_id`: String, `schema_version`: Int64, `source_type`: String) {
            self.`capability_id` = `capability_id`
            self.`platforms` = `platforms`
            self.`protocol` = `protocol`
            self.`schema_id` = `schema_id`
            self.`schema_version` = `schema_version`
            self.`source_type` = `source_type`
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
    public struct EventReceipt: Codable, Sendable, Equatable {
        public var `code`: String
        public var `event_id`: String
        public var `status`: String
        public init(`code`: String, `event_id`: String, `status`: String) {
            self.`code` = `code`
            self.`event_id` = `event_id`
            self.`status` = `status`
        }
    }
    public struct ExtensionFieldOption: Codable, Sendable, Equatable {
        public var `label`: String
        public var `value`: String
        public init(`label`: String, `value`: String) {
            self.`label` = `label`
            self.`value` = `value`
        }
    }
    public struct ExtensionFieldOptionResponse: Codable, Sendable, Equatable {
        public var `label`: String
        public var `label_translated`: String?
        public var `value`: String
        public init(`label`: String, `label_translated`: String? = nil, `value`: String) {
            self.`label` = `label`
            self.`label_translated` = `label_translated`
            self.`value` = `value`
        }
    }
    public struct ExtensionFieldResponse: Codable, Sendable, Equatable {
        public var `default`: JSONValue?
        public var `depends_on_key`: String?
        public var `depends_on_values`: [String]?
        public var `description`: String?
        public var `description_translated`: String?
        public var `key`: String
        public var `label`: String
        public var `label_translated`: String?
        public var `maximum`: Double?
        public var `minimum`: Double?
        public var `options`: [ExtensionFieldOptionResponse]?
        public var `order`: Int64?
        public var `path_kind`: String?
        public var `placeholder`: String?
        public var `required`: Bool?
        public var `section`: String?
        public var `section_note_translated`: String?
        public var `section_translated`: String?
        public var `surface`: String?
        public var `type`: String?
        public init(`default`: JSONValue? = nil, `depends_on_key`: String? = nil, `depends_on_values`: [String]? = nil, `description`: String? = nil, `description_translated`: String? = nil, `key`: String, `label`: String, `label_translated`: String? = nil, `maximum`: Double? = nil, `minimum`: Double? = nil, `options`: [ExtensionFieldOptionResponse]? = nil, `order`: Int64? = nil, `path_kind`: String? = nil, `placeholder`: String? = nil, `required`: Bool? = nil, `section`: String? = nil, `section_note_translated`: String? = nil, `section_translated`: String? = nil, `surface`: String? = nil, `type`: String? = nil) {
            self.`default` = `default`
            self.`depends_on_key` = `depends_on_key`
            self.`depends_on_values` = `depends_on_values`
            self.`description` = `description`
            self.`description_translated` = `description_translated`
            self.`key` = `key`
            self.`label` = `label`
            self.`label_translated` = `label_translated`
            self.`maximum` = `maximum`
            self.`minimum` = `minimum`
            self.`options` = `options`
            self.`order` = `order`
            self.`path_kind` = `path_kind`
            self.`placeholder` = `placeholder`
            self.`required` = `required`
            self.`section` = `section`
            self.`section_note_translated` = `section_note_translated`
            self.`section_translated` = `section_translated`
            self.`surface` = `surface`
            self.`type` = `type`
        }
    }
    public struct ExtensionFieldSpec: Codable, Sendable, Equatable {
        public var `default`: JSONValue?
        public var `depends_on_key`: String?
        public var `depends_on_values`: [String]?
        public var `description`: String?
        public var `key`: String
        public var `label`: String
        public var `maximum`: Double?
        public var `minimum`: Double?
        public var `options`: [ExtensionFieldOption]?
        public var `order`: Int64?
        public var `path_kind`: String?
        public var `placeholder`: String?
        public var `required`: Bool?
        public var `section`: String?
        public var `surface`: String?
        public var `type`: String?
        public init(`default`: JSONValue? = nil, `depends_on_key`: String? = nil, `depends_on_values`: [String]? = nil, `description`: String? = nil, `key`: String, `label`: String, `maximum`: Double? = nil, `minimum`: Double? = nil, `options`: [ExtensionFieldOption]? = nil, `order`: Int64? = nil, `path_kind`: String? = nil, `placeholder`: String? = nil, `required`: Bool? = nil, `section`: String? = nil, `surface`: String? = nil, `type`: String? = nil) {
            self.`default` = `default`
            self.`depends_on_key` = `depends_on_key`
            self.`depends_on_values` = `depends_on_values`
            self.`description` = `description`
            self.`key` = `key`
            self.`label` = `label`
            self.`maximum` = `maximum`
            self.`minimum` = `minimum`
            self.`options` = `options`
            self.`order` = `order`
            self.`path_kind` = `path_kind`
            self.`placeholder` = `placeholder`
            self.`required` = `required`
            self.`section` = `section`
            self.`surface` = `surface`
            self.`type` = `type`
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
    public struct GatewayClientInfo: Codable, Sendable, Equatable {
        public var `client_id`: String
        public var `collector_scope`: GatewayCollectorScope?
        public var `created_at_ms`: Int64
        public var `name`: String
        public var `revoked_at_ms`: JSONValue
        public var `role`: String
        public init(`client_id`: String, `collector_scope`: GatewayCollectorScope? = nil, `created_at_ms`: Int64, `name`: String, `revoked_at_ms`: JSONValue, `role`: String) {
            self.`client_id` = `client_id`
            self.`collector_scope` = `collector_scope`
            self.`created_at_ms` = `created_at_ms`
            self.`name` = `name`
            self.`revoked_at_ms` = `revoked_at_ms`
            self.`role` = `role`
        }
    }
    public struct GatewayCollectorScope: Codable, Sendable, Equatable {
        public var `connection_id`: String
        public var `source_type`: String
        public init(`connection_id`: String, `source_type`: String) {
            self.`connection_id` = `connection_id`
            self.`source_type` = `source_type`
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
    public struct GatewayPairingGrant: Codable, Sendable, Equatable {
        public var `expires_at_ms`: Int64
        public var `pairing_token`: String
        public var `server_id`: String
        public init(`expires_at_ms`: Int64, `pairing_token`: String, `server_id`: String) {
            self.`expires_at_ms` = `expires_at_ms`
            self.`pairing_token` = `pairing_token`
            self.`server_id` = `server_id`
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
    public struct LocalRequirementAppInstalled: Codable, Sendable, Equatable {
        public var `check_kind`: String?
        public var `identifier_per_platform`: [String: String]
        public init(`check_kind`: String? = nil, `identifier_per_platform`: [String: String]) {
            self.`check_kind` = `check_kind`
            self.`identifier_per_platform` = `identifier_per_platform`
        }
    }
    public struct LocalRequirementExecutableInPath: Codable, Sendable, Equatable {
        public var `check_kind`: String?
        public var `names`: [String]
        public init(`check_kind`: String? = nil, `names`: [String]) {
            self.`check_kind` = `check_kind`
            self.`names` = `names`
        }
    }
    public struct LocalRequirementFileExists: Codable, Sendable, Equatable {
        public var `check_kind`: String?
        public var `paths_per_platform`: [String: String]
        public init(`check_kind`: String? = nil, `paths_per_platform`: [String: String]) {
            self.`check_kind` = `check_kind`
            self.`paths_per_platform` = `paths_per_platform`
        }
    }
    public struct LocalizedText: Codable, Sendable, Equatable {
        public var `en`: String
        public var `zh`: String
        public init(`en`: String, `zh`: String) {
            self.`en` = `en`
            self.`zh` = `zh`
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
    public struct MemoryContextCondition: Codable, Sendable, Equatable {
        public var `context_id`: String
        public var `dimension`: String
        public init(`context_id`: String, `dimension`: String) {
            self.`context_id` = `context_id`
            self.`dimension` = `dimension`
        }
    }
    public struct MemoryContextScope: Codable, Sendable, Equatable {
        public var `all_of`: [MemoryContextCondition]
        public init(`all_of`: [MemoryContextCondition]) {
            self.`all_of` = `all_of`
        }
    }
    public struct MemoryCorrectionClaimValue: Codable, Sendable, Equatable {
        public var `display_status`: String?
        public var `display_text`: String?
        public var `fact_kind`: String?
        public var `object_id`: String?
        public var `object_type`: String?
        public var `predicate`: String?
        public var `scope`: MemoryStoredContextScope?
        public var `status`: String?
        public var `subject_id`: String?
        public var `subject_type`: String?
        public var `trait_value`: JSONValue?
        public var `validation_state`: String?
        public var `value`: JSONValue?
        public var `value_options`: [String]?
        public init(`display_status`: String? = nil, `display_text`: String? = nil, `fact_kind`: String? = nil, `object_id`: String? = nil, `object_type`: String? = nil, `predicate`: String? = nil, `scope`: MemoryStoredContextScope? = nil, `status`: String? = nil, `subject_id`: String? = nil, `subject_type`: String? = nil, `trait_value`: JSONValue? = nil, `validation_state`: String? = nil, `value`: JSONValue? = nil, `value_options`: [String]? = nil) {
            self.`display_status` = `display_status`
            self.`display_text` = `display_text`
            self.`fact_kind` = `fact_kind`
            self.`object_id` = `object_id`
            self.`object_type` = `object_type`
            self.`predicate` = `predicate`
            self.`scope` = `scope`
            self.`status` = `status`
            self.`subject_id` = `subject_id`
            self.`subject_type` = `subject_type`
            self.`trait_value` = `trait_value`
            self.`validation_state` = `validation_state`
            self.`value` = `value`
            self.`value_options` = `value_options`
        }
    }
    public struct MemoryCorrectionCommandResponse: Codable, Sendable, Equatable {
        public var `correction`: MemoryCorrectionRecord
        public var `created`: Bool
        public var `current_claim`: MemoryCorrectionClaimValue?
        public var `derivation_state`: String
        public var `subject_revision`: Int64?
        public init(`correction`: MemoryCorrectionRecord, `created`: Bool, `current_claim`: MemoryCorrectionClaimValue? = nil, `derivation_state`: String, `subject_revision`: Int64? = nil) {
            self.`correction` = `correction`
            self.`created` = `created`
            self.`current_claim` = `current_claim`
            self.`derivation_state` = `derivation_state`
            self.`subject_revision` = `subject_revision`
        }
    }
    public struct MemoryCorrectionHistoryResponse: Codable, Sendable, Equatable {
        public var `context_labels`: [String: String]?
        public var `corrections`: [MemoryCorrectionRecord]?
        public var `target`: MemoryCorrectionTarget
        public var `versions`: [MemoryCorrectionVersion]?
        public init(`context_labels`: [String: String]? = nil, `corrections`: [MemoryCorrectionRecord]? = nil, `target`: MemoryCorrectionTarget, `versions`: [MemoryCorrectionVersion]? = nil) {
            self.`context_labels` = `context_labels`
            self.`corrections` = `corrections`
            self.`target` = `target`
            self.`versions` = `versions`
        }
    }
    public struct MemoryCorrectionRecord: Codable, Sendable, Equatable {
        public var `before`: MemoryCorrectionClaimValue?
        public var `can_revert`: Bool?
        public var `content_redacted`: Bool?
        public var `correction_id`: String
        public var `correction_kind`: String
        public var `created_at`: Double
        public var `effective_at`: Double?
        public var `forget_affected`: Bool?
        public var `reason`: String?
        public var `replacement`: MemoryCorrectionClaimValue?
        public var `resolution_reason`: String?
        public var `revert_blocked_reason`: String?
        public var `scope`: MemoryStoredContextScope?
        public var `state`: String
        public var `target_forgotten`: Bool?
        public var `transition_applied_at`: Double?
        public var `transition_cancelled_at`: Double?
        public init(`before`: MemoryCorrectionClaimValue? = nil, `can_revert`: Bool? = nil, `content_redacted`: Bool? = nil, `correction_id`: String, `correction_kind`: String, `created_at`: Double, `effective_at`: Double? = nil, `forget_affected`: Bool? = nil, `reason`: String? = nil, `replacement`: MemoryCorrectionClaimValue? = nil, `resolution_reason`: String? = nil, `revert_blocked_reason`: String? = nil, `scope`: MemoryStoredContextScope? = nil, `state`: String, `target_forgotten`: Bool? = nil, `transition_applied_at`: Double? = nil, `transition_cancelled_at`: Double? = nil) {
            self.`before` = `before`
            self.`can_revert` = `can_revert`
            self.`content_redacted` = `content_redacted`
            self.`correction_id` = `correction_id`
            self.`correction_kind` = `correction_kind`
            self.`created_at` = `created_at`
            self.`effective_at` = `effective_at`
            self.`forget_affected` = `forget_affected`
            self.`reason` = `reason`
            self.`replacement` = `replacement`
            self.`resolution_reason` = `resolution_reason`
            self.`revert_blocked_reason` = `revert_blocked_reason`
            self.`scope` = `scope`
            self.`state` = `state`
            self.`target_forgotten` = `target_forgotten`
            self.`transition_applied_at` = `transition_applied_at`
            self.`transition_cancelled_at` = `transition_cancelled_at`
        }
    }
    public struct MemoryCorrectionRequest: Codable, Sendable, Equatable {
        public var `correction_kind`: String
        public var `effective_at`: Double?
        public var `expected_updated_at`: Double?
        public var `reason`: String?
        public var `replacement`: [String: JSONValue]?
        public var `request_id`: String
        public var `scope`: MemoryContextScope?
        public var `source_event_id`: String?
        public var `target`: MemoryCorrectionTarget
        public init(`correction_kind`: String, `effective_at`: Double? = nil, `expected_updated_at`: Double? = nil, `reason`: String? = nil, `replacement`: [String: JSONValue]? = nil, `request_id`: String, `scope`: MemoryContextScope? = nil, `source_event_id`: String? = nil, `target`: MemoryCorrectionTarget) {
            self.`correction_kind` = `correction_kind`
            self.`effective_at` = `effective_at`
            self.`expected_updated_at` = `expected_updated_at`
            self.`reason` = `reason`
            self.`replacement` = `replacement`
            self.`request_id` = `request_id`
            self.`scope` = `scope`
            self.`source_event_id` = `source_event_id`
            self.`target` = `target`
        }
    }
    public struct MemoryCorrectionTarget: Codable, Sendable, Equatable {
        public var `id`: String
        public var `kind`: String
        public init(`id`: String, `kind`: String) {
            self.`id` = `id`
            self.`kind` = `kind`
        }
    }
    public struct MemoryCorrectionVersion: Codable, Sendable, Equatable {
        public var `created_at`: Double?
        public var `display_status`: String?
        public var `display_text`: String?
        public var `first_inferred_at`: Double?
        public var `first_observed_at`: Double?
        public var `object_id`: String?
        public var `object_type`: String?
        public var `predicate`: String?
        public var `scope`: MemoryStoredContextScope?
        public var `status`: String?
        public var `subject_id`: String?
        public var `subject_type`: String?
        public var `trait_value`: JSONValue?
        public var `valid_from`: Double?
        public var `valid_to`: Double?
        public var `validation_state`: String?
        public var `value_options`: [String]?
        public init(`created_at`: Double? = nil, `display_status`: String? = nil, `display_text`: String? = nil, `first_inferred_at`: Double? = nil, `first_observed_at`: Double? = nil, `object_id`: String? = nil, `object_type`: String? = nil, `predicate`: String? = nil, `scope`: MemoryStoredContextScope? = nil, `status`: String? = nil, `subject_id`: String? = nil, `subject_type`: String? = nil, `trait_value`: JSONValue? = nil, `valid_from`: Double? = nil, `valid_to`: Double? = nil, `validation_state`: String? = nil, `value_options`: [String]? = nil) {
            self.`created_at` = `created_at`
            self.`display_status` = `display_status`
            self.`display_text` = `display_text`
            self.`first_inferred_at` = `first_inferred_at`
            self.`first_observed_at` = `first_observed_at`
            self.`object_id` = `object_id`
            self.`object_type` = `object_type`
            self.`predicate` = `predicate`
            self.`scope` = `scope`
            self.`status` = `status`
            self.`subject_id` = `subject_id`
            self.`subject_type` = `subject_type`
            self.`trait_value` = `trait_value`
            self.`valid_from` = `valid_from`
            self.`valid_to` = `valid_to`
            self.`validation_state` = `validation_state`
            self.`value_options` = `value_options`
        }
    }
    public struct MemoryLibraryItem: Codable, Sendable, Equatable {
        public var `assertion_id`: String?
        public var `can_delete`: Bool?
        public var `correction_options`: [String]?
        public var `correction_value`: String?
        public var `evidence_ids`: [String]?
        public var `id`: String
        public var `kind`: String
        public var `needs_review`: Bool?
        public var `source`: String?
        public var `text`: String
        public var `timestamp`: Double?
        public var `title`: String?
        public var `updated_at`: Double?
        public init(`assertion_id`: String? = nil, `can_delete`: Bool? = nil, `correction_options`: [String]? = nil, `correction_value`: String? = nil, `evidence_ids`: [String]? = nil, `id`: String, `kind`: String, `needs_review`: Bool? = nil, `source`: String? = nil, `text`: String, `timestamp`: Double? = nil, `title`: String? = nil, `updated_at`: Double? = nil) {
            self.`assertion_id` = `assertion_id`
            self.`can_delete` = `can_delete`
            self.`correction_options` = `correction_options`
            self.`correction_value` = `correction_value`
            self.`evidence_ids` = `evidence_ids`
            self.`id` = `id`
            self.`kind` = `kind`
            self.`needs_review` = `needs_review`
            self.`source` = `source`
            self.`text` = `text`
            self.`timestamp` = `timestamp`
            self.`title` = `title`
            self.`updated_at` = `updated_at`
        }
    }
    public struct MemoryLibraryPage: Codable, Sendable, Equatable {
        public var `items`: [MemoryLibraryItem]
        public var `limit`: Int64
        public var `offset`: Int64
        public var `stale`: Bool?
        public var `total`: Int64
        public init(`items`: [MemoryLibraryItem], `limit`: Int64, `offset`: Int64, `stale`: Bool? = nil, `total`: Int64) {
            self.`items` = `items`
            self.`limit` = `limit`
            self.`offset` = `offset`
            self.`stale` = `stale`
            self.`total` = `total`
        }
    }
    public struct MemoryStoredContextCondition: Codable, Sendable, Equatable {
        public var `context_id`: String
        public var `dimension`: String
        public init(`context_id`: String, `dimension`: String) {
            self.`context_id` = `context_id`
            self.`dimension` = `dimension`
        }
    }
    public struct MemoryStoredContextScope: Codable, Sendable, Equatable {
        public var `all_of`: [MemoryStoredContextCondition]
        public init(`all_of`: [MemoryStoredContextCondition]) {
            self.`all_of` = `all_of`
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
    public struct NotificationRead: Codable, Sendable, Equatable {
        public var `kind`: String
        public var `notification_id`: Int64
        public init(`kind`: String, `notification_id`: Int64) {
            self.`kind` = `kind`
            self.`notification_id` = `notification_id`
        }
    }
    public struct ObservationChange: Codable, Sendable, Equatable {
        public var `object_id`: String
        public var `occurred_at`: Double?
        public var `operation`: String?
        public var `payload`: [String: JsonValue]?
        public var `resources`: [ResourceRef]?
        public var `version`: String
        public init(`object_id`: String, `occurred_at`: Double? = nil, `operation`: String? = nil, `payload`: [String: JsonValue]? = nil, `resources`: [ResourceRef]? = nil, `version`: String) {
            self.`object_id` = `object_id`
            self.`occurred_at` = `occurred_at`
            self.`operation` = `operation`
            self.`payload` = `payload`
            self.`resources` = `resources`
            self.`version` = `version`
        }
    }
    public struct PackageTrustRequest: Codable, Sendable, Equatable {
        public var `expected_capabilities`: [PluginCapability]
        public var `expected_execution_mode`: String
        public var `expected_package_sha256`: String
        public init(`expected_capabilities`: [PluginCapability], `expected_execution_mode`: String, `expected_package_sha256`: String) {
            self.`expected_capabilities` = `expected_capabilities`
            self.`expected_execution_mode` = `expected_execution_mode`
            self.`expected_package_sha256` = `expected_package_sha256`
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
    public struct PluginCapability: Codable, Sendable, Equatable {
        public var `capability`: String
        public var `optional`: Bool?
        public var `reason`: String?
        public var `reason_i18n`: [String: String]?
        public var `scope`: [String]?
        public init(`capability`: String, `optional`: Bool? = nil, `reason`: String? = nil, `reason_i18n`: [String: String]? = nil, `scope`: [String]? = nil) {
            self.`capability` = `capability`
            self.`optional` = `optional`
            self.`reason` = `reason`
            self.`reason_i18n` = `reason_i18n`
            self.`scope` = `scope`
        }
    }
    public struct PluginConnectionResponse: Codable, Sendable, Equatable {
        public var `connection_id`: String
        public var `credential_refs`: [String: String]?
        public var `display_name`: String
        public var `enabled`: Bool?
        public var `plugin_id`: String
        public var `readiness`: [CapabilityReadiness]
        public var `revision`: Int64?
        public var `settings`: [String: JsonValue]?
        public init(`connection_id`: String, `credential_refs`: [String: String]? = nil, `display_name`: String, `enabled`: Bool? = nil, `plugin_id`: String, `readiness`: [CapabilityReadiness], `revision`: Int64? = nil, `settings`: [String: JsonValue]? = nil) {
            self.`connection_id` = `connection_id`
            self.`credential_refs` = `credential_refs`
            self.`display_name` = `display_name`
            self.`enabled` = `enabled`
            self.`plugin_id` = `plugin_id`
            self.`readiness` = `readiness`
            self.`revision` = `revision`
            self.`settings` = `settings`
        }
    }
    public struct PluginConnectionsResponse: Codable, Sendable, Equatable {
        public var `connections`: [PluginConnectionResponse]
        public var `total`: Int64
        public init(`connections`: [PluginConnectionResponse], `total`: Int64) {
            self.`connections` = `connections`
            self.`total` = `total`
        }
    }
    public struct PluginContributionResponse: Codable, Sendable, Equatable {
        public var `contribution_id`: String
        public var `contribution_type`: String
        public var `description`: String
        public var `display_name`: String
        public var `fields`: [ExtensionFieldResponse]?
        public var `metadata`: [String: JSONValue]?
        public var `plugin_id`: String
        public var `surface`: String
        public init(`contribution_id`: String, `contribution_type`: String, `description`: String, `display_name`: String, `fields`: [ExtensionFieldResponse]? = nil, `metadata`: [String: JSONValue]? = nil, `plugin_id`: String, `surface`: String) {
            self.`contribution_id` = `contribution_id`
            self.`contribution_type` = `contribution_type`
            self.`description` = `description`
            self.`display_name` = `display_name`
            self.`fields` = `fields`
            self.`metadata` = `metadata`
            self.`plugin_id` = `plugin_id`
            self.`surface` = `surface`
        }
    }
    public struct PluginDisplayGroupSpec: Codable, Sendable, Equatable {
        public var `description`: String?
        public var `description_i18n`: [String: String]?
        public var `icon`: String?
        public var `id`: String
        public var `member_label`: String?
        public var `member_label_i18n`: [String: String]?
        public var `member_order`: Int64?
        public var `name`: String
        public var `name_i18n`: [String: String]?
        public var `order`: Int64?
        public init(`description`: String? = nil, `description_i18n`: [String: String]? = nil, `icon`: String? = nil, `id`: String, `member_label`: String? = nil, `member_label_i18n`: [String: String]? = nil, `member_order`: Int64? = nil, `name`: String, `name_i18n`: [String: String]? = nil, `order`: Int64? = nil) {
            self.`description` = `description`
            self.`description_i18n` = `description_i18n`
            self.`icon` = `icon`
            self.`id` = `id`
            self.`member_label` = `member_label`
            self.`member_label_i18n` = `member_label_i18n`
            self.`member_order` = `member_order`
            self.`name` = `name`
            self.`name_i18n` = `name_i18n`
            self.`order` = `order`
        }
    }
    public struct PluginEvent: Codable, Sendable, Equatable {
        public var `connection_epoch`: String
        public var `connection_id`: String
        public var `data`: [String: JsonValue]
        public var `event_type`: String
        public var `kind`: String
        public var `plugin_target`: String
        public init(`connection_epoch`: String, `connection_id`: String, `data`: [String: JsonValue], `event_type`: String, `kind`: String, `plugin_target`: String) {
            self.`connection_epoch` = `connection_epoch`
            self.`connection_id` = `connection_id`
            self.`data` = `data`
            self.`event_type` = `event_type`
            self.`kind` = `kind`
            self.`plugin_target` = `plugin_target`
        }
    }
    public struct PluginInstallCandidateApprovalRequest: Codable, Sendable, Equatable {
        public var `expected_sha256`: String
        public init(`expected_sha256`: String) {
            self.`expected_sha256` = `expected_sha256`
        }
    }
    public struct PluginInstallCandidateResponse: Codable, Sendable, Equatable {
        public var `archive_sha256`: String
        public var `candidate_id`: String
        public var `expires_at_ms`: Int64
        public var `manifest`: PluginManifestResponse
        public var `package_sha256`: String
        public init(`archive_sha256`: String, `candidate_id`: String, `expires_at_ms`: Int64, `manifest`: PluginManifestResponse, `package_sha256`: String) {
            self.`archive_sha256` = `archive_sha256`
            self.`candidate_id` = `candidate_id`
            self.`expires_at_ms` = `expires_at_ms`
            self.`manifest` = `manifest`
            self.`package_sha256` = `package_sha256`
        }
    }
    public struct PluginInstallJobSnapshot: Codable, Sendable, Equatable {
        public var `created_at_ms`: Int64
        public var `error`: String?
        public var `error_code`: String?
        public var `filename`: String?
        public var `finished_at_ms`: Int64?
        public var `job_id`: String
        public var `logs`: [PluginInstallLogEntry]?
        public var `message`: String
        public var `operation`: String
        public var `plugin_id`: String?
        public var `progress_pct`: Double?
        public var `result`: PluginPackageResponse?
        public var `stage`: String
        public var `status`: String
        public var `updated_at_ms`: Int64
        public init(`created_at_ms`: Int64, `error`: String? = nil, `error_code`: String? = nil, `filename`: String? = nil, `finished_at_ms`: Int64? = nil, `job_id`: String, `logs`: [PluginInstallLogEntry]? = nil, `message`: String, `operation`: String, `plugin_id`: String? = nil, `progress_pct`: Double? = nil, `result`: PluginPackageResponse? = nil, `stage`: String, `status`: String, `updated_at_ms`: Int64) {
            self.`created_at_ms` = `created_at_ms`
            self.`error` = `error`
            self.`error_code` = `error_code`
            self.`filename` = `filename`
            self.`finished_at_ms` = `finished_at_ms`
            self.`job_id` = `job_id`
            self.`logs` = `logs`
            self.`message` = `message`
            self.`operation` = `operation`
            self.`plugin_id` = `plugin_id`
            self.`progress_pct` = `progress_pct`
            self.`result` = `result`
            self.`stage` = `stage`
            self.`status` = `status`
            self.`updated_at_ms` = `updated_at_ms`
        }
    }
    public struct PluginInstallLogEntry: Codable, Sendable, Equatable {
        public var `level`: String?
        public var `message`: String
        public var `stage`: String
        public var `ts_ms`: Int64
        public init(`level`: String? = nil, `message`: String, `stage`: String, `ts_ms`: Int64) {
            self.`level` = `level`
            self.`message` = `message`
            self.`stage` = `stage`
            self.`ts_ms` = `ts_ms`
        }
    }
    public struct PluginInstallPlanChangeResponse: Codable, Sendable, Equatable {
        public var `action`: String
        public var `current_dependency_package_sha256`: [String: JSONValue]
        public var `current_installed_package_sha256`: String?
        public var `current_package_sha256`: String?
        public var `current_version`: String?
        public var `dependency_package_sha256`: [String: JSONValue]
        public var `entry`: PluginRegistryEntry
        public var `reason`: String
        public init(`action`: String, `current_dependency_package_sha256`: [String: JSONValue], `current_installed_package_sha256`: String? = nil, `current_package_sha256`: String? = nil, `current_version`: String? = nil, `dependency_package_sha256`: [String: JSONValue], `entry`: PluginRegistryEntry, `reason`: String) {
            self.`action` = `action`
            self.`current_dependency_package_sha256` = `current_dependency_package_sha256`
            self.`current_installed_package_sha256` = `current_installed_package_sha256`
            self.`current_package_sha256` = `current_package_sha256`
            self.`current_version` = `current_version`
            self.`dependency_package_sha256` = `dependency_package_sha256`
            self.`entry` = `entry`
            self.`reason` = `reason`
        }
    }
    public struct PluginInstallPlanRequest: Codable, Sendable, Equatable {
        public var `plugin_id`: String
        public var `update`: Bool
        public init(`plugin_id`: String, `update`: Bool) {
            self.`plugin_id` = `plugin_id`
            self.`update` = `update`
        }
    }
    public struct PluginInstallPlanResponse: Codable, Sendable, Equatable {
        public var `changes`: [PluginInstallPlanChangeResponse]
        public var `coordinated`: Bool
        public var `fingerprint`: String
        public var `format`: String
        public var `registry_fingerprint`: String
        public var `target_id`: String
        public var `update`: Bool
        public init(`changes`: [PluginInstallPlanChangeResponse], `coordinated`: Bool, `fingerprint`: String, `format`: String, `registry_fingerprint`: String, `target_id`: String, `update`: Bool) {
            self.`changes` = `changes`
            self.`coordinated` = `coordinated`
            self.`fingerprint` = `fingerprint`
            self.`format` = `format`
            self.`registry_fingerprint` = `registry_fingerprint`
            self.`target_id` = `target_id`
            self.`update` = `update`
        }
    }
    public struct PluginInstallRequest: Codable, Sendable, Equatable {
        public var `plan_fingerprint`: String
        public var `plugin_id`: String
        public init(`plan_fingerprint`: String, `plugin_id`: String) {
            self.`plan_fingerprint` = `plan_fingerprint`
            self.`plugin_id` = `plugin_id`
        }
    }
    public struct PluginManifestResponse: Codable, Sendable, Equatable {
        public var `activation_flow`: ActivationFlowResponse?
        public var `author`: String
        public var `capabilities`: [PluginCapability]?
        public var `consented_capabilities`: [PluginCapability]?
        public var `contribution_types`: [String]
        public var `description`: String
        public var `device_collectors`: [DeviceCollectorSpec]?
        public var `display_group`: PluginDisplayGroupSpec?
        public var `execution_mode`: String
        public var `icon`: String?
        public var `manifest_path`: String
        public var `min_sdk_version`: String
        public var `name`: String
        public var `official`: Bool
        public var `plugin_dir`: String
        public var `plugin_id`: String
        public var `protocol_version`: Int64
        public var `settings_actions`: [PluginSettingsActionResponse]?
        public var `settings_fields`: [ExtensionFieldResponse]
        public var `settings_resources`: [PluginSettingsResourceSpec]?
        public var `settings_ui_blocks`: [PluginSettingsUiBlockResponse]?
        public var `source`: String
        public var `version`: String
        public init(`activation_flow`: ActivationFlowResponse? = nil, `author`: String, `capabilities`: [PluginCapability]? = nil, `consented_capabilities`: [PluginCapability]? = nil, `contribution_types`: [String], `description`: String, `device_collectors`: [DeviceCollectorSpec]? = nil, `display_group`: PluginDisplayGroupSpec? = nil, `execution_mode`: String, `icon`: String? = nil, `manifest_path`: String, `min_sdk_version`: String, `name`: String, `official`: Bool, `plugin_dir`: String, `plugin_id`: String, `protocol_version`: Int64, `settings_actions`: [PluginSettingsActionResponse]? = nil, `settings_fields`: [ExtensionFieldResponse], `settings_resources`: [PluginSettingsResourceSpec]? = nil, `settings_ui_blocks`: [PluginSettingsUiBlockResponse]? = nil, `source`: String, `version`: String) {
            self.`activation_flow` = `activation_flow`
            self.`author` = `author`
            self.`capabilities` = `capabilities`
            self.`consented_capabilities` = `consented_capabilities`
            self.`contribution_types` = `contribution_types`
            self.`description` = `description`
            self.`device_collectors` = `device_collectors`
            self.`display_group` = `display_group`
            self.`execution_mode` = `execution_mode`
            self.`icon` = `icon`
            self.`manifest_path` = `manifest_path`
            self.`min_sdk_version` = `min_sdk_version`
            self.`name` = `name`
            self.`official` = `official`
            self.`plugin_dir` = `plugin_dir`
            self.`plugin_id` = `plugin_id`
            self.`protocol_version` = `protocol_version`
            self.`settings_actions` = `settings_actions`
            self.`settings_fields` = `settings_fields`
            self.`settings_resources` = `settings_resources`
            self.`settings_ui_blocks` = `settings_ui_blocks`
            self.`source` = `source`
            self.`version` = `version`
        }
    }
    public struct PluginPackageResponse: Codable, Sendable, Equatable {
        public var `contributions`: [PluginContributionResponse]?
        public var `current_settings`: [String: JSONValue]?
        public var `enabled`: Bool
        public var `healthy`: Bool
        public var `last_error`: String?
        public var `loaded`: Bool
        public var `manifest`: PluginManifestResponse
        public var `package_sha256`: String?
        public var `trusted`: Bool
        public init(`contributions`: [PluginContributionResponse]? = nil, `current_settings`: [String: JSONValue]? = nil, `enabled`: Bool, `healthy`: Bool, `last_error`: String? = nil, `loaded`: Bool, `manifest`: PluginManifestResponse, `package_sha256`: String? = nil, `trusted`: Bool) {
            self.`contributions` = `contributions`
            self.`current_settings` = `current_settings`
            self.`enabled` = `enabled`
            self.`healthy` = `healthy`
            self.`last_error` = `last_error`
            self.`loaded` = `loaded`
            self.`manifest` = `manifest`
            self.`package_sha256` = `package_sha256`
            self.`trusted` = `trusted`
        }
    }
    public struct PluginRegistryApprovalRequest: Codable, Sendable, Equatable {
        public var `plan_fingerprint`: String
        public init(`plan_fingerprint`: String) {
            self.`plan_fingerprint` = `plan_fingerprint`
        }
    }
    public struct PluginRegistryEntry: Codable, Sendable, Equatable {
        public var `activation_flow`: ActivationFlowSpec?
        public var `author`: String?
        public var `capabilities`: [PluginCapability]?
        public var `contribution_types`: [String]?
        public var `data_locality`: String?
        public var `depends_on`: [String]?
        public var `description`: String?
        public var `description_i18n`: [String: String]?
        public var `device_collectors`: [DeviceCollectorSpec]?
        public var `display_group`: PluginDisplayGroupSpec?
        public var `execution_mode`: String?
        public var `homepage`: String?
        public var `icon`: String?
        public var `icon_data`: String?
        public var `kind`: String?
        public var `min_sdk_version`: String?
        public var `name`: String
        public var `name_i18n`: [String: String]?
        public var `official`: Bool?
        public var `package_sha256`: String
        public var `path`: String?
        public var `platforms`: [String]?
        public var `plugin_id`: String
        public var `projection_sources`: [String]?
        public var `protocol_version`: Int64?
        public var `repository`: String?
        public var `settings_actions`: [PluginSettingsActionSpec]?
        public var `settings_fields`: [ExtensionFieldSpec]?
        public var `settings_resources`: [PluginSettingsResourceSpec]?
        public var `settings_ui_blocks`: [SettingsUIBlockSpec]?
        public var `suggestion_descriptor`: SuggestionDescriptor?
        public var `version`: String
        public init(`activation_flow`: ActivationFlowSpec? = nil, `author`: String? = nil, `capabilities`: [PluginCapability]? = nil, `contribution_types`: [String]? = nil, `data_locality`: String? = nil, `depends_on`: [String]? = nil, `description`: String? = nil, `description_i18n`: [String: String]? = nil, `device_collectors`: [DeviceCollectorSpec]? = nil, `display_group`: PluginDisplayGroupSpec? = nil, `execution_mode`: String? = nil, `homepage`: String? = nil, `icon`: String? = nil, `icon_data`: String? = nil, `kind`: String? = nil, `min_sdk_version`: String? = nil, `name`: String, `name_i18n`: [String: String]? = nil, `official`: Bool? = nil, `package_sha256`: String, `path`: String? = nil, `platforms`: [String]? = nil, `plugin_id`: String, `projection_sources`: [String]? = nil, `protocol_version`: Int64? = nil, `repository`: String? = nil, `settings_actions`: [PluginSettingsActionSpec]? = nil, `settings_fields`: [ExtensionFieldSpec]? = nil, `settings_resources`: [PluginSettingsResourceSpec]? = nil, `settings_ui_blocks`: [SettingsUIBlockSpec]? = nil, `suggestion_descriptor`: SuggestionDescriptor? = nil, `version`: String) {
            self.`activation_flow` = `activation_flow`
            self.`author` = `author`
            self.`capabilities` = `capabilities`
            self.`contribution_types` = `contribution_types`
            self.`data_locality` = `data_locality`
            self.`depends_on` = `depends_on`
            self.`description` = `description`
            self.`description_i18n` = `description_i18n`
            self.`device_collectors` = `device_collectors`
            self.`display_group` = `display_group`
            self.`execution_mode` = `execution_mode`
            self.`homepage` = `homepage`
            self.`icon` = `icon`
            self.`icon_data` = `icon_data`
            self.`kind` = `kind`
            self.`min_sdk_version` = `min_sdk_version`
            self.`name` = `name`
            self.`name_i18n` = `name_i18n`
            self.`official` = `official`
            self.`package_sha256` = `package_sha256`
            self.`path` = `path`
            self.`platforms` = `platforms`
            self.`plugin_id` = `plugin_id`
            self.`projection_sources` = `projection_sources`
            self.`protocol_version` = `protocol_version`
            self.`repository` = `repository`
            self.`settings_actions` = `settings_actions`
            self.`settings_fields` = `settings_fields`
            self.`settings_resources` = `settings_resources`
            self.`settings_ui_blocks` = `settings_ui_blocks`
            self.`suggestion_descriptor` = `suggestion_descriptor`
            self.`version` = `version`
        }
    }
    public struct PluginRegistryEntryResponse: Codable, Sendable, Equatable {
        public var `activation_flow`: ActivationFlowSpec?
        public var `author`: String?
        public var `capabilities`: [PluginCapability]?
        public var `contribution_types`: [String]?
        public var `data_locality`: String?
        public var `description`: String?
        public var `description_i18n`: [String: String]?
        public var `device_collectors`: [DeviceCollectorSpec]?
        public var `display_group`: PluginDisplayGroupSpec?
        public var `execution_mode`: String
        public var `homepage`: String?
        public var `icon`: String?
        public var `installed`: Bool?
        public var `installed_version`: String?
        public var `min_sdk_version`: String
        public var `name`: String
        public var `name_i18n`: [String: String]?
        public var `official`: Bool?
        public var `path`: String?
        public var `platforms`: [String]?
        public var `plugin_id`: String
        public var `protocol_version`: Int64
        public var `repository`: String?
        public var `settings_actions`: [PluginSettingsActionSpec]?
        public var `settings_fields`: [ExtensionFieldSpec]?
        public var `settings_resources`: [PluginSettingsResourceSpec]?
        public var `settings_ui_blocks`: [SettingsUIBlockSpec]?
        public var `update_available`: Bool?
        public var `version`: String
        public init(`activation_flow`: ActivationFlowSpec? = nil, `author`: String? = nil, `capabilities`: [PluginCapability]? = nil, `contribution_types`: [String]? = nil, `data_locality`: String? = nil, `description`: String? = nil, `description_i18n`: [String: String]? = nil, `device_collectors`: [DeviceCollectorSpec]? = nil, `display_group`: PluginDisplayGroupSpec? = nil, `execution_mode`: String, `homepage`: String? = nil, `icon`: String? = nil, `installed`: Bool? = nil, `installed_version`: String? = nil, `min_sdk_version`: String, `name`: String, `name_i18n`: [String: String]? = nil, `official`: Bool? = nil, `path`: String? = nil, `platforms`: [String]? = nil, `plugin_id`: String, `protocol_version`: Int64, `repository`: String? = nil, `settings_actions`: [PluginSettingsActionSpec]? = nil, `settings_fields`: [ExtensionFieldSpec]? = nil, `settings_resources`: [PluginSettingsResourceSpec]? = nil, `settings_ui_blocks`: [SettingsUIBlockSpec]? = nil, `update_available`: Bool? = nil, `version`: String) {
            self.`activation_flow` = `activation_flow`
            self.`author` = `author`
            self.`capabilities` = `capabilities`
            self.`contribution_types` = `contribution_types`
            self.`data_locality` = `data_locality`
            self.`description` = `description`
            self.`description_i18n` = `description_i18n`
            self.`device_collectors` = `device_collectors`
            self.`display_group` = `display_group`
            self.`execution_mode` = `execution_mode`
            self.`homepage` = `homepage`
            self.`icon` = `icon`
            self.`installed` = `installed`
            self.`installed_version` = `installed_version`
            self.`min_sdk_version` = `min_sdk_version`
            self.`name` = `name`
            self.`name_i18n` = `name_i18n`
            self.`official` = `official`
            self.`path` = `path`
            self.`platforms` = `platforms`
            self.`plugin_id` = `plugin_id`
            self.`protocol_version` = `protocol_version`
            self.`repository` = `repository`
            self.`settings_actions` = `settings_actions`
            self.`settings_fields` = `settings_fields`
            self.`settings_resources` = `settings_resources`
            self.`settings_ui_blocks` = `settings_ui_blocks`
            self.`update_available` = `update_available`
            self.`version` = `version`
        }
    }
    public struct PluginRegistryResponse: Codable, Sendable, Equatable {
        public var `install_fingerprint`: String
        public var `plugins`: [PluginRegistryEntryResponse]?
        public var `registry_version`: String
        public init(`install_fingerprint`: String, `plugins`: [PluginRegistryEntryResponse]? = nil, `registry_version`: String) {
            self.`install_fingerprint` = `install_fingerprint`
            self.`plugins` = `plugins`
            self.`registry_version` = `registry_version`
        }
    }
    public struct PluginRequestResolution: Codable, Sendable, Equatable {
        public var `operator_reviewed`: Bool
        public init(`operator_reviewed`: Bool) {
            self.`operator_reviewed` = `operator_reviewed`
        }
    }
    public struct PluginRpcReceipt: Codable, Sendable, Equatable {
        public var `http_status`: Int64?
        public var `operation_id`: String
        public var `result`: JsonValue
        public var `state`: String
        public init(`http_status`: Int64? = nil, `operation_id`: String, `result`: JsonValue, `state`: String) {
            self.`http_status` = `http_status`
            self.`operation_id` = `operation_id`
            self.`result` = `result`
            self.`state` = `state`
        }
    }
    public struct PluginSettingsActionRequest: Codable, Sendable, Equatable {
        public var `field_values`: [String: JSONValue]?
        public init(`field_values`: [String: JSONValue]? = nil) {
            self.`field_values` = `field_values`
        }
    }
    public struct PluginSettingsActionResponse: Codable, Sendable, Equatable {
        public var `action_id`: String
        public var `button_label`: String?
        public var `button_label_translated`: String?
        public var `contribution_id`: String?
        public var `contribution_type`: ContributionType?
        public var `depends_on_key`: String?
        public var `depends_on_values`: [String]?
        public var `description`: String?
        public var `description_translated`: String?
        public var `destructive`: Bool?
        public var `label`: String
        public var `label_translated`: String?
        public var `order`: Int64?
        public var `persist_settings_on_success`: Bool?
        public var `poll_interval_ms`: Int64?
        public var `presentation`: String?
        public var `requires_enabled`: Bool?
        public var `surface`: String?
        public var `timeout_ms`: Int64?
        public init(`action_id`: String, `button_label`: String? = nil, `button_label_translated`: String? = nil, `contribution_id`: String? = nil, `contribution_type`: ContributionType? = nil, `depends_on_key`: String? = nil, `depends_on_values`: [String]? = nil, `description`: String? = nil, `description_translated`: String? = nil, `destructive`: Bool? = nil, `label`: String, `label_translated`: String? = nil, `order`: Int64? = nil, `persist_settings_on_success`: Bool? = nil, `poll_interval_ms`: Int64? = nil, `presentation`: String? = nil, `requires_enabled`: Bool? = nil, `surface`: String? = nil, `timeout_ms`: Int64? = nil) {
            self.`action_id` = `action_id`
            self.`button_label` = `button_label`
            self.`button_label_translated` = `button_label_translated`
            self.`contribution_id` = `contribution_id`
            self.`contribution_type` = `contribution_type`
            self.`depends_on_key` = `depends_on_key`
            self.`depends_on_values` = `depends_on_values`
            self.`description` = `description`
            self.`description_translated` = `description_translated`
            self.`destructive` = `destructive`
            self.`label` = `label`
            self.`label_translated` = `label_translated`
            self.`order` = `order`
            self.`persist_settings_on_success` = `persist_settings_on_success`
            self.`poll_interval_ms` = `poll_interval_ms`
            self.`presentation` = `presentation`
            self.`requires_enabled` = `requires_enabled`
            self.`surface` = `surface`
            self.`timeout_ms` = `timeout_ms`
        }
    }
    public struct PluginSettingsActionRunResponse: Codable, Sendable, Equatable {
        public var `action_id`: String
        public var `connection_id`: String
        public var `data`: [String: JSONValue]?
        public var `message`: String?
        public var `plugin_id`: String
        public var `session_id`: String
        public var `settings_updates`: [String: JSONValue]?
        public var `status`: String
        public init(`action_id`: String, `connection_id`: String, `data`: [String: JSONValue]? = nil, `message`: String? = nil, `plugin_id`: String, `session_id`: String, `settings_updates`: [String: JSONValue]? = nil, `status`: String) {
            self.`action_id` = `action_id`
            self.`connection_id` = `connection_id`
            self.`data` = `data`
            self.`message` = `message`
            self.`plugin_id` = `plugin_id`
            self.`session_id` = `session_id`
            self.`settings_updates` = `settings_updates`
            self.`status` = `status`
        }
    }
    public struct PluginSettingsActionSpec: Codable, Sendable, Equatable {
        public var `action_id`: String
        public var `button_label`: String?
        public var `contribution_id`: String?
        public var `contribution_type`: ContributionType?
        public var `depends_on_key`: String?
        public var `depends_on_values`: [String]?
        public var `description`: String?
        public var `destructive`: Bool?
        public var `label`: String
        public var `order`: Int64?
        public var `persist_settings_on_success`: Bool?
        public var `poll_interval_ms`: Int64?
        public var `presentation`: String?
        public var `requires_enabled`: Bool?
        public var `surface`: String?
        public var `timeout_ms`: Int64?
        public init(`action_id`: String, `button_label`: String? = nil, `contribution_id`: String? = nil, `contribution_type`: ContributionType? = nil, `depends_on_key`: String? = nil, `depends_on_values`: [String]? = nil, `description`: String? = nil, `destructive`: Bool? = nil, `label`: String, `order`: Int64? = nil, `persist_settings_on_success`: Bool? = nil, `poll_interval_ms`: Int64? = nil, `presentation`: String? = nil, `requires_enabled`: Bool? = nil, `surface`: String? = nil, `timeout_ms`: Int64? = nil) {
            self.`action_id` = `action_id`
            self.`button_label` = `button_label`
            self.`contribution_id` = `contribution_id`
            self.`contribution_type` = `contribution_type`
            self.`depends_on_key` = `depends_on_key`
            self.`depends_on_values` = `depends_on_values`
            self.`description` = `description`
            self.`destructive` = `destructive`
            self.`label` = `label`
            self.`order` = `order`
            self.`persist_settings_on_success` = `persist_settings_on_success`
            self.`poll_interval_ms` = `poll_interval_ms`
            self.`presentation` = `presentation`
            self.`requires_enabled` = `requires_enabled`
            self.`surface` = `surface`
            self.`timeout_ms` = `timeout_ms`
        }
    }
    public struct PluginSettingsResourceResponse: Codable, Sendable, Equatable {
        public var `connection_id`: String
        public var `data`: JSONValue?
        public var `plugin_id`: String
        public var `resource_name`: String
        public var `resource_type`: String
        public init(`connection_id`: String, `data`: JSONValue? = nil, `plugin_id`: String, `resource_name`: String, `resource_type`: String) {
            self.`connection_id` = `connection_id`
            self.`data` = `data`
            self.`plugin_id` = `plugin_id`
            self.`resource_name` = `resource_name`
            self.`resource_type` = `resource_type`
        }
    }
    public struct PluginSettingsResourceSpec: Codable, Sendable, Equatable {
        public var `description`: String?
        public var `metadata`: [String: JSONValue]?
        public var `requires_enabled`: Bool?
        public var `resource_name`: String
        public var `resource_type`: String?
        public init(`description`: String? = nil, `metadata`: [String: JSONValue]? = nil, `requires_enabled`: Bool? = nil, `resource_name`: String, `resource_type`: String? = nil) {
            self.`description` = `description`
            self.`metadata` = `metadata`
            self.`requires_enabled` = `requires_enabled`
            self.`resource_name` = `resource_name`
            self.`resource_type` = `resource_type`
        }
    }
    public struct PluginSettingsUiBlockResponse: Codable, Sendable, Equatable {
        public var `block_id`: String
        public var `depends_on_key`: String?
        public var `depends_on_values`: [String]?
        public var `description`: String?
        public var `description_translated`: String?
        public var `presentation`: String?
        public var `resource_name`: String
        public var `title`: String
        public var `title_translated`: String?
        public var `type`: String?
        public var `value_key`: String
        public init(`block_id`: String, `depends_on_key`: String? = nil, `depends_on_values`: [String]? = nil, `description`: String? = nil, `description_translated`: String? = nil, `presentation`: String? = nil, `resource_name`: String, `title`: String, `title_translated`: String? = nil, `type`: String? = nil, `value_key`: String) {
            self.`block_id` = `block_id`
            self.`depends_on_key` = `depends_on_key`
            self.`depends_on_values` = `depends_on_values`
            self.`description` = `description`
            self.`description_translated` = `description_translated`
            self.`presentation` = `presentation`
            self.`resource_name` = `resource_name`
            self.`title` = `title`
            self.`title_translated` = `title_translated`
            self.`type` = `type`
            self.`value_key` = `value_key`
        }
    }
    public struct PluginUpdateCheckResponse: Codable, Sendable, Equatable {
        public var `current_version`: String
        public var `latest_version`: String
        public var `plugin_id`: String
        public var `update_available`: Bool
        public init(`current_version`: String, `latest_version`: String, `plugin_id`: String, `update_available`: Bool) {
            self.`current_version` = `current_version`
            self.`latest_version` = `latest_version`
            self.`plugin_id` = `plugin_id`
            self.`update_available` = `update_available`
        }
    }
    public struct PluginsListResponse: Codable, Sendable, Equatable {
        public var `plugins`: [PluginPackageResponse]
        public var `total`: Int64
        public init(`plugins`: [PluginPackageResponse], `total`: Int64) {
            self.`plugins` = `plugins`
            self.`total` = `total`
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
    public struct ResourceRef: Codable, Sendable, Equatable {
        public var `connection_id`: String
        public var `display_name`: String?
        public var `media_type`: String
        public var `resource_id`: String
        public var `size_bytes`: Int64
        public var `version`: String
        public init(`connection_id`: String, `display_name`: String? = nil, `media_type`: String, `resource_id`: String, `size_bytes`: Int64, `version`: String) {
            self.`connection_id` = `connection_id`
            self.`display_name` = `display_name`
            self.`media_type` = `media_type`
            self.`resource_id` = `resource_id`
            self.`size_bytes` = `size_bytes`
            self.`version` = `version`
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
    public struct ReviewPatch: Codable, Sendable, Equatable {
        public var `review_state`: String
        public var `user_note`: String?
        public init(`review_state`: String, `user_note`: String? = nil) {
            self.`review_state` = `review_state`
            self.`user_note` = `user_note`
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
    public struct SettingsUIBlockSpec: Codable, Sendable, Equatable {
        public var `block_id`: String
        public var `depends_on_key`: String?
        public var `depends_on_values`: [String]?
        public var `description`: String?
        public var `presentation`: String?
        public var `resource_name`: String
        public var `title`: String
        public var `type`: String?
        public var `value_key`: String
        public init(`block_id`: String, `depends_on_key`: String? = nil, `depends_on_values`: [String]? = nil, `description`: String? = nil, `presentation`: String? = nil, `resource_name`: String, `title`: String, `type`: String? = nil, `value_key`: String) {
            self.`block_id` = `block_id`
            self.`depends_on_key` = `depends_on_key`
            self.`depends_on_values` = `depends_on_values`
            self.`description` = `description`
            self.`presentation` = `presentation`
            self.`resource_name` = `resource_name`
            self.`title` = `title`
            self.`type` = `type`
            self.`value_key` = `value_key`
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
    public struct SourceCatalogItem: Codable, Sendable, Equatable {
        public var `description`: String?
        public var `description_i18n`: [String: String]?
        public var `icon`: String?
        public var `installed`: Bool
        public var `name`: String
        public var `name_i18n`: [String: String]?
        public var `plugin_id`: String
        public var `scope`: [String: String]?
        public var `status`: String
        public init(`description`: String? = nil, `description_i18n`: [String: String]? = nil, `icon`: String? = nil, `installed`: Bool, `name`: String, `name_i18n`: [String: String]? = nil, `plugin_id`: String, `scope`: [String: String]? = nil, `status`: String) {
            self.`description` = `description`
            self.`description_i18n` = `description_i18n`
            self.`icon` = `icon`
            self.`installed` = `installed`
            self.`name` = `name`
            self.`name_i18n` = `name_i18n`
            self.`plugin_id` = `plugin_id`
            self.`scope` = `scope`
            self.`status` = `status`
        }
    }
    public struct SourceCatalogResponse: Codable, Sendable, Equatable {
        public var `catalog_mode`: String
        public var `items`: [SourceCatalogItem]
        public init(`catalog_mode`: String, `items`: [SourceCatalogItem]) {
            self.`catalog_mode` = `catalog_mode`
            self.`items` = `items`
        }
    }
    public struct SourceObservation: Codable, Sendable, Equatable {
        public var `capability_id`: String
        public var `change`: ObservationChange
        public var `connection_epoch`: String
        public var `connection_id`: String
        public var `kind`: String
        public var `protocol`: String
        public var `schema_id`: String
        public var `schema_version`: Int64
        public var `source_type`: String
        public init(`capability_id`: String, `change`: ObservationChange, `connection_epoch`: String, `connection_id`: String, `kind`: String, `protocol`: String, `schema_id`: String, `schema_version`: Int64, `source_type`: String) {
            self.`capability_id` = `capability_id`
            self.`change` = `change`
            self.`connection_epoch` = `connection_epoch`
            self.`connection_id` = `connection_id`
            self.`kind` = `kind`
            self.`protocol` = `protocol`
            self.`schema_id` = `schema_id`
            self.`schema_version` = `schema_version`
            self.`source_type` = `source_type`
        }
    }
    public struct SuggestionDescriptor: Codable, Sendable, Equatable {
        public var `category`: String
        public var `data_locality`: String?
        public var `icon`: String?
        public var `local_requirements`: [JSONValue]?
        public var `platform_support`: [String]
        public var `rationale`: LocalizedText
        public var `setup_time_estimate_seconds`: Int64?
        public var `surfaces`: SuggestionSurfacesSpec?
        public var `triggers`: Triggers
        public init(`category`: String, `data_locality`: String? = nil, `icon`: String? = nil, `local_requirements`: [JSONValue]? = nil, `platform_support`: [String], `rationale`: LocalizedText, `setup_time_estimate_seconds`: Int64? = nil, `surfaces`: SuggestionSurfacesSpec? = nil, `triggers`: Triggers) {
            self.`category` = `category`
            self.`data_locality` = `data_locality`
            self.`icon` = `icon`
            self.`local_requirements` = `local_requirements`
            self.`platform_support` = `platform_support`
            self.`rationale` = `rationale`
            self.`setup_time_estimate_seconds` = `setup_time_estimate_seconds`
            self.`surfaces` = `surfaces`
            self.`triggers` = `triggers`
        }
    }
    public struct SuggestionSurfaceSpec: Codable, Sendable, Equatable {
        public var `order`: Int64?
        public var `rationale`: LocalizedText?
        public var `scope`: LocalizedText?
        public init(`order`: Int64? = nil, `rationale`: LocalizedText? = nil, `scope`: LocalizedText? = nil) {
            self.`order` = `order`
            self.`rationale` = `rationale`
            self.`scope` = `scope`
        }
    }
    public struct SuggestionSurfacesSpec: Codable, Sendable, Equatable {
        public var `empty_state`: SuggestionSurfaceSpec?
        public var `first_context`: SuggestionSurfaceSpec?
        public init(`empty_state`: SuggestionSurfaceSpec? = nil, `first_context`: SuggestionSurfaceSpec? = nil) {
            self.`empty_state` = `empty_state`
            self.`first_context` = `first_context`
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
    public struct Triggers: Codable, Sendable, Equatable {
        public var `entities`: [String]?
        public var `intents`: [String]?
        public var `keywords`: [String: [String]]?
        public init(`entities`: [String]? = nil, `intents`: [String]? = nil, `keywords`: [String: [String]]? = nil) {
            self.`entities` = `entities`
            self.`intents` = `intents`
            self.`keywords` = `keywords`
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
