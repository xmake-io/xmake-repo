option("webrtc", {default = false, showmenu = true})

add_rules("mode.debug", "mode.release")

add_requires("protobuf-cpp")

if not is_plat("windows") then
    add_requires("openssl")
end

if has_config("webrtc") then
    add_requires("abseil")
    target("webrtc-lite")
        add_rules("c++")
        set_kind("static")
        add_packages("protobuf-cpp")

        if is_plat("windows") then
            add_defines("WEBRTC_WIN", "NOMINMAX", "WIN32_LEAN_AND_MEAN", "_WINSOCKAPI_")
            add_cxflags("/wd4715", "/wd4005", "/wd4996", "/wd4530")
        else
            add_ldflags("-Wl", "--no-undefined")
            add_defines("WEBRTC_POSIX", "WEBRTC_LINUX")
        end
        local files = {
            "src/external/webrtc/api/adaptation/resource.cc",
            "src/external/webrtc/api/adaptation/resource.h",
            "src/external/webrtc/api/array_view.h",
            "src/external/webrtc/api/async_resolver_factory.h",
            "src/external/webrtc/api/candidate.cc",
            "src/external/webrtc/api/candidate.h",
            "src/external/webrtc/api/crypto_params.h",
            "src/external/webrtc/api/crypto/crypto_options.cc",
            "src/external/webrtc/api/crypto/crypto_options.h",
            "src/external/webrtc/api/crypto/frame_decryptor_interface.h",
            "src/external/webrtc/api/crypto/frame_encryptor_interface.h",
            "src/external/webrtc/api/dtls_transport_interface.cc",
            "src/external/webrtc/api/dtls_transport_interface.h",
            "src/external/webrtc/api/dtmf_sender_interface.h",
            "src/external/webrtc/api/fec_controller_override.h",
            "src/external/webrtc/api/fec_controller.h",
            "src/external/webrtc/api/frame_transformer_interface.h",
            "src/external/webrtc/api/function_view.h",
            "src/external/webrtc/api/ice_transport_interface.h",
            "src/external/webrtc/api/neteq/neteq_factory.h",
            "src/external/webrtc/api/neteq/neteq.cc",
            "src/external/webrtc/api/neteq/neteq.h",
            "src/external/webrtc/api/network_state_predictor.h",
            "src/external/webrtc/api/packet_socket_factory.h",
            "src/external/webrtc/api/priority.h",
            "src/external/webrtc/api/proxy.cc",
            "src/external/webrtc/api/proxy.h",
            "src/external/webrtc/api/ref_counted_base.h",
            "src/external/webrtc/api/rtc_error.cc",
            "src/external/webrtc/api/rtc_error.h",
            "src/external/webrtc/api/rtc_event_log/rtc_event.cc",
            "src/external/webrtc/api/rtc_event_log/rtc_event.h",
            "src/external/webrtc/api/scoped_refptr.h",
            "src/external/webrtc/api/task_queue/default_task_queue_factory.h",
            "src/external/webrtc/api/task_queue/queued_task.h",
            "src/external/webrtc/api/task_queue/task_queue_base.cc",
            "src/external/webrtc/api/task_queue/task_queue_base.h",
            "src/external/webrtc/api/task_queue/task_queue_factory.h",
            "src/external/webrtc/api/transport/bitrate_settings.cc",
            "src/external/webrtc/api/transport/bitrate_settings.h",
            "src/external/webrtc/api/transport/data_channel_transport_interface.h",
            "src/external/webrtc/api/transport/enums.h",
            "src/external/webrtc/api/transport/network_control.h",
            "src/external/webrtc/api/transport/network_types.cc",
            "src/external/webrtc/api/transport/network_types.h",
            "src/external/webrtc/api/transport/rtp/dependency_descriptor.cc",
            "src/external/webrtc/api/transport/rtp/dependency_descriptor.h",
            "src/external/webrtc/api/transport/rtp/rtp_source.h",
            "src/external/webrtc/api/transport/stun.cc",
            "src/external/webrtc/api/transport/stun.h",
            "src/external/webrtc/api/transport/webrtc_key_value_config.h",
            "src/external/webrtc/api/turn_customizer.h",
            "src/external/webrtc/api/units/data_rate.cc",
            "src/external/webrtc/api/units/data_rate.h",
            "src/external/webrtc/api/units/data_size.cc",
            "src/external/webrtc/api/units/data_size.h",
            "src/external/webrtc/api/units/frequency.cc",
            "src/external/webrtc/api/units/frequency.h",
            "src/external/webrtc/api/units/time_delta.cc",
            "src/external/webrtc/api/units/time_delta.h",
            "src/external/webrtc/api/units/timestamp.cc",
            "src/external/webrtc/api/units/timestamp.h",
            "src/external/webrtc/common_types.h",
            "src/external/webrtc/logging/rtc_event_log/events/rtc_event_dtls_transport_state.cc",
            "src/external/webrtc/logging/rtc_event_log/events/rtc_event_dtls_transport_state.h",
            "src/external/webrtc/logging/rtc_event_log/events/rtc_event_dtls_writable_state.cc",
            "src/external/webrtc/logging/rtc_event_log/events/rtc_event_dtls_writable_state.h",
            "src/external/webrtc/logging/rtc_event_log/events/rtc_event_ice_candidate_pair_config.cc",
            "src/external/webrtc/logging/rtc_event_log/events/rtc_event_ice_candidate_pair_config.h",
            "src/external/webrtc/logging/rtc_event_log/events/rtc_event_ice_candidate_pair.cc",
            "src/external/webrtc/logging/rtc_event_log/events/rtc_event_ice_candidate_pair.h",
            "src/external/webrtc/logging/rtc_event_log/ice_logger.cc",
            "src/external/webrtc/logging/rtc_event_log/ice_logger.h",
            "src/external/webrtc/modules/utility/include/process_thread.h",
            "src/external/webrtc/p2p/base/async_stun_tcp_socket.cc",
            "src/external/webrtc/p2p/base/async_stun_tcp_socket.h",
            "src/external/webrtc/p2p/base/basic_ice_controller.cc",
            "src/external/webrtc/p2p/base/basic_ice_controller.h",
            "src/external/webrtc/p2p/base/basic_packet_socket_factory.cc",
            "src/external/webrtc/p2p/base/basic_packet_socket_factory.cc",
            "src/external/webrtc/p2p/base/basic_packet_socket_factory.h",
            "src/external/webrtc/p2p/base/candidate_pair_interface.h",
            "src/external/webrtc/p2p/base/connection_info.cc",
            "src/external/webrtc/p2p/base/connection_info.h",
            "src/external/webrtc/p2p/base/connection.cc",
            "src/external/webrtc/p2p/base/connection.h",
            "src/external/webrtc/p2p/base/dtls_transport_internal.cc",
            "src/external/webrtc/p2p/base/dtls_transport_internal.h",
            "src/external/webrtc/p2p/base/dtls_transport.cc",
            "src/external/webrtc/p2p/base/dtls_transport.h",
            "src/external/webrtc/p2p/base/ice_controller_factory_interface.h",
            "src/external/webrtc/p2p/base/ice_controller_interface.cc",
            "src/external/webrtc/p2p/base/ice_controller_interface.h",
            "src/external/webrtc/p2p/base/ice_credentials_iterator.cc",
            "src/external/webrtc/p2p/base/ice_credentials_iterator.h",
            "src/external/webrtc/p2p/base/ice_transport_internal.cc",
            "src/external/webrtc/p2p/base/ice_transport_internal.h",
            "src/external/webrtc/p2p/base/p2p_constants.cc",
            "src/external/webrtc/p2p/base/p2p_constants.h",
            "src/external/webrtc/p2p/base/p2p_transport_channel_ice_field_trials.h",
            "src/external/webrtc/p2p/base/p2p_transport_channel.cc",
            "src/external/webrtc/p2p/base/p2p_transport_channel.cc",
            "src/external/webrtc/p2p/base/p2p_transport_channel.h",
            "src/external/webrtc/p2p/base/packet_transport_internal.cc",
            "src/external/webrtc/p2p/base/packet_transport_internal.h",
            "src/external/webrtc/p2p/base/port_allocator.cc",
            "src/external/webrtc/p2p/base/port_allocator.h",
            "src/external/webrtc/p2p/base/port_interface.cc",
            "src/external/webrtc/p2p/base/port_interface.h",
            "src/external/webrtc/p2p/base/port.cc",
            "src/external/webrtc/p2p/base/port.h",
            "src/external/webrtc/p2p/base/regathering_controller.cc",
            "src/external/webrtc/p2p/base/regathering_controller.h",
            "src/external/webrtc/p2p/base/stun_port.cc",
            "src/external/webrtc/p2p/base/stun_port.h",
            "src/external/webrtc/p2p/base/stun_request.cc",
            "src/external/webrtc/p2p/base/stun_request.h",
            "src/external/webrtc/p2p/base/tcp_port.cc",
            "src/external/webrtc/p2p/base/tcp_port.h",
            "src/external/webrtc/p2p/base/transport_description_factory.cc",
            "src/external/webrtc/p2p/base/transport_description_factory.h",
            "src/external/webrtc/p2p/base/transport_description.cc",
            "src/external/webrtc/p2p/base/transport_description.h",
            "src/external/webrtc/p2p/base/transport_info.h",
            "src/external/webrtc/p2p/base/turn_port.cc",
            "src/external/webrtc/p2p/base/turn_port.h",
            "src/external/webrtc/p2p/base/udp_port.h",
            "src/external/webrtc/p2p/client/basic_port_allocator.cc",
            "src/external/webrtc/p2p/client/basic_port_allocator.cc",
            "src/external/webrtc/p2p/client/basic_port_allocator.h",
            "src/external/webrtc/p2p/client/relay_port_factory_interface.h",
            "src/external/webrtc/p2p/client/turn_port_factory.cc",
            "src/external/webrtc/p2p/client/turn_port_factory.h",
            "src/external/webrtc/pc/channel_interface.h",
            "src/external/webrtc/pc/channel_manager.cc",
            "src/external/webrtc/pc/channel_manager.cc",
            "src/external/webrtc/pc/channel_manager.h",
            "src/external/webrtc/pc/channel.cc",
            "src/external/webrtc/pc/channel.h",
            "src/external/webrtc/pc/dtls_transport.cc",
            "src/external/webrtc/pc/dtls_transport.h",
            "src/external/webrtc/pc/ice_transport.cc",
            "src/external/webrtc/pc/ice_transport.h",
            "src/external/webrtc/pc/sdp_serializer.cc",
            "src/external/webrtc/pc/sdp_serializer.h",
            "src/external/webrtc/pc/session_description.cc",
            "src/external/webrtc/pc/session_description.h",
            "src/external/webrtc/pc/simulcast_description.cc",
            "src/external/webrtc/pc/simulcast_description.h",
            "src/external/webrtc/pc/transport_stats.cc",
            "src/external/webrtc/pc/transport_stats.h",
            "src/external/webrtc/pc/used_ids.h",
            "src/external/steamwebrtc/webrtc_sdp.cc",   -- NOTE: This is a file that we had to hack.  See the comments at the top of the file for more info.
            "src/external/webrtc/pc/webrtc_sdp.h",
            "src/external/webrtc/rtc_base/arraysize.h",
            "src/external/webrtc/rtc_base/async_invoker_inl.h",
            "src/external/webrtc/rtc_base/async_invoker.cc",
            "src/external/webrtc/rtc_base/async_invoker.h",
            "src/external/webrtc/rtc_base/async_packet_socket.cc",
            "src/external/webrtc/rtc_base/async_packet_socket.h",
            "src/external/webrtc/rtc_base/async_resolver_interface.cc",
            "src/external/webrtc/rtc_base/async_resolver_interface.h",
            "src/external/webrtc/rtc_base/async_socket.cc",
            "src/external/webrtc/rtc_base/async_socket.h",
            "src/external/webrtc/rtc_base/async_tcp_socket.cc",
            "src/external/webrtc/rtc_base/async_tcp_socket.h",
            "src/external/webrtc/rtc_base/async_udp_socket.cc",
            "src/external/webrtc/rtc_base/async_udp_socket.h",
            "src/external/webrtc/rtc_base/atomic_ops.h",
            "src/external/webrtc/rtc_base/bind.h",
            "src/external/webrtc/rtc_base/bit_buffer.cc",
            "src/external/webrtc/rtc_base/buffer_queue.cc",
            "src/external/webrtc/rtc_base/buffer_queue.h",
            "src/external/webrtc/rtc_base/buffer.h",
            "src/external/webrtc/rtc_base/byte_buffer.cc",
            "src/external/webrtc/rtc_base/byte_buffer.h",
            "src/external/webrtc/rtc_base/byte_order.h",
            "src/external/webrtc/rtc_base/callback.h",
            "src/external/webrtc/rtc_base/checks.cc",
            "src/external/webrtc/rtc_base/checks.h",
            "src/external/webrtc/rtc_base/constructor_magic.h",
            "src/external/webrtc/rtc_base/copy_on_write_buffer.cc",
            "src/external/webrtc/rtc_base/copy_on_write_buffer.h",
            "src/external/webrtc/rtc_base/crc32.cc",
            "src/external/webrtc/rtc_base/crc32.h",
            "src/external/webrtc/rtc_base/critical_section.cc",
            "src/external/webrtc/rtc_base/critical_section.h",
            "src/external/webrtc/rtc_base/crypt_string.cc",
            "src/external/webrtc/rtc_base/crypt_string.h",
            "src/external/webrtc/rtc_base/deprecated/signal_thread.cc",
            "src/external/webrtc/rtc_base/deprecated/signal_thread.h",
            "src/external/webrtc/rtc_base/deprecation.h",
            "src/external/webrtc/rtc_base/dscp.h",
            "src/external/webrtc/rtc_base/event_tracer.cc",
            "src/external/webrtc/rtc_base/event_tracer.cc",
            "src/external/webrtc/rtc_base/event_tracer.h",
            "src/external/webrtc/rtc_base/event.cc",
            "src/external/webrtc/rtc_base/event.h",
            "src/external/webrtc/rtc_base/experiments/field_trial_parser.cc",
            "src/external/webrtc/rtc_base/experiments/field_trial_parser.h",
            "src/external/webrtc/rtc_base/experiments/field_trial_units.cc",
            "src/external/webrtc/rtc_base/experiments/field_trial_units.h",
            "src/external/webrtc/rtc_base/experiments/struct_parameters_parser.cc",
            "src/external/webrtc/rtc_base/experiments/struct_parameters_parser.h",
            "src/external/webrtc/rtc_base/helpers.cc",
            "src/external/webrtc/rtc_base/helpers.h",
            "src/external/webrtc/rtc_base/http_common.cc",
            "src/external/webrtc/rtc_base/http_common.cc",
            "src/external/webrtc/rtc_base/http_common.h",
            "src/external/webrtc/rtc_base/ip_address.cc",
            "src/external/webrtc/rtc_base/ip_address.h",
            "src/external/webrtc/rtc_base/location.cc",
            "src/external/webrtc/rtc_base/location.h",
            "src/external/webrtc/rtc_base/logging.cc",
            "src/external/webrtc/rtc_base/logging.h",
            "src/external/webrtc/rtc_base/mdns_responder_interface.h",
            "src/external/webrtc/rtc_base/message_digest.cc",
            "src/external/webrtc/rtc_base/message_digest.h",
            "src/external/webrtc/rtc_base/message_handler.cc",
            "src/external/webrtc/rtc_base/message_handler.h",
            "src/external/webrtc/rtc_base/net_helper.cc",
            "src/external/webrtc/rtc_base/net_helper.h",
            "src/external/webrtc/rtc_base/net_helpers.cc",
            "src/external/webrtc/rtc_base/net_helpers.h",
            "src/external/webrtc/rtc_base/network_constants.cc",
            "src/external/webrtc/rtc_base/network_constants.h",
            "src/external/webrtc/rtc_base/network_monitor.cc",
            "src/external/webrtc/rtc_base/network_monitor.h",
            "src/external/webrtc/rtc_base/network_route.cc",
            "src/external/webrtc/rtc_base/network_route.h",
            "src/external/webrtc/rtc_base/network.cc",
            "src/external/webrtc/rtc_base/network.h",
            "src/external/webrtc/rtc_base/network/sent_packet.cc",
            "src/external/webrtc/rtc_base/network/sent_packet.h",
            "src/external/webrtc/rtc_base/null_socket_server.cc",
            "src/external/webrtc/rtc_base/null_socket_server.h",
            "src/external/webrtc/rtc_base/numerics/event_based_exponential_moving_average.cc",
            "src/external/webrtc/rtc_base/numerics/event_based_exponential_moving_average.h",
            "src/external/webrtc/rtc_base/numerics/safe_compare.h",
            "src/external/webrtc/rtc_base/numerics/safe_conversions_impl.h",
            "src/external/webrtc/rtc_base/numerics/safe_conversions.h",
            "src/external/webrtc/rtc_base/numerics/safe_minmax.h",
            "src/external/webrtc/rtc_base/openssl_adapter.cc",
            "src/external/webrtc/rtc_base/openssl_adapter.h",
            "src/external/webrtc/rtc_base/openssl_certificate.cc",
            "src/external/webrtc/rtc_base/openssl_certificate.h",
            "src/external/webrtc/rtc_base/openssl_digest.cc",
            "src/external/webrtc/rtc_base/openssl_digest.h",
            "src/external/webrtc/rtc_base/openssl_identity.cc",
            "src/external/webrtc/rtc_base/openssl_identity.h",
            "src/external/webrtc/rtc_base/openssl_session_cache.cc",
            "src/external/webrtc/rtc_base/openssl_session_cache.h",
            "src/external/webrtc/rtc_base/openssl_stream_adapter.cc",
            "src/external/webrtc/rtc_base/openssl_stream_adapter.h",
            "src/external/webrtc/rtc_base/openssl_utility.cc",
            "src/external/webrtc/rtc_base/openssl_utility.h",
            "src/external/webrtc/rtc_base/openssl.h",
            "src/external/webrtc/rtc_base/physical_socket_server.cc",
            "src/external/webrtc/rtc_base/physical_socket_server.h",
            "src/external/webrtc/rtc_base/platform_thread_types.cc",
            "src/external/webrtc/rtc_base/platform_thread_types.h",
            "src/external/webrtc/rtc_base/platform_thread.cc",
            "src/external/webrtc/rtc_base/platform_thread.cc",
            "src/external/webrtc/rtc_base/platform_thread.h",
            "src/external/webrtc/rtc_base/proxy_info.cc",
            "src/external/webrtc/rtc_base/proxy_info.h",
            "src/external/webrtc/rtc_base/rate_tracker.cc",
            "src/external/webrtc/rtc_base/rate_tracker.h",
            "src/external/webrtc/rtc_base/ref_count.h",
            "src/external/webrtc/rtc_base/ref_counted_object.h",
            "src/external/webrtc/rtc_base/ref_counter.h",
            "src/external/webrtc/rtc_base/rtc_certificate.cc",
            "src/external/webrtc/rtc_base/rtc_certificate.h",
            "src/external/webrtc/rtc_base/sanitizer.h",
            "src/external/webrtc/rtc_base/signal_thread.h",
            "src/external/webrtc/rtc_base/socket_adapters.cc",
            "src/external/webrtc/rtc_base/socket_adapters.h",
            "src/external/webrtc/rtc_base/socket_address.cc",
            "src/external/webrtc/rtc_base/socket_address.h",
            "src/external/webrtc/rtc_base/socket_factory.h",
            "src/external/webrtc/rtc_base/socket_server.h",
            "src/external/webrtc/rtc_base/socket.cc",
            "src/external/webrtc/rtc_base/socket.h",
            "src/external/webrtc/rtc_base/ssl_adapter.cc",
            "src/external/webrtc/rtc_base/ssl_adapter.h",
            "src/external/webrtc/rtc_base/ssl_certificate.cc",
            "src/external/webrtc/rtc_base/ssl_certificate.h",
            "src/external/webrtc/rtc_base/ssl_fingerprint.cc",
            "src/external/webrtc/rtc_base/ssl_fingerprint.h",
            "src/external/webrtc/rtc_base/ssl_identity.cc",
            "src/external/webrtc/rtc_base/ssl_identity.h",
            "src/external/webrtc/rtc_base/ssl_roots.h",
            "src/external/webrtc/rtc_base/ssl_stream_adapter.cc",
            "src/external/webrtc/rtc_base/ssl_stream_adapter.h",
            "src/external/webrtc/rtc_base/stream.cc",
            "src/external/webrtc/rtc_base/stream.h",
            "src/external/webrtc/rtc_base/string_encode.cc",
            "src/external/webrtc/rtc_base/string_encode.h",
            "src/external/webrtc/rtc_base/string_to_number.cc",
            "src/external/webrtc/rtc_base/string_to_number.h",
            "src/external/webrtc/rtc_base/string_utils.cc",
            "src/external/webrtc/rtc_base/string_utils.h",
            "src/external/webrtc/rtc_base/stringize_macros.h",
            "src/external/webrtc/rtc_base/strings/string_builder.cc",
            "src/external/webrtc/rtc_base/strings/string_builder.h",
            "src/external/webrtc/rtc_base/synchronization/mutex_critical_section.h",
            "src/external/webrtc/rtc_base/synchronization/mutex.cc",
            "src/external/webrtc/rtc_base/synchronization/mutex.h",
            "src/external/webrtc/rtc_base/synchronization/rw_lock_wrapper.cc",
            "src/external/webrtc/rtc_base/synchronization/rw_lock_wrapper.h",
            "src/external/webrtc/rtc_base/synchronization/sequence_checker.cc",
            "src/external/webrtc/rtc_base/synchronization/sequence_checker.h",
            "src/external/webrtc/rtc_base/synchronization/yield_policy.cc",
            "src/external/webrtc/rtc_base/synchronization/yield_policy.cc",
            "src/external/webrtc/rtc_base/synchronization/yield_policy.h",
            "src/external/webrtc/rtc_base/synchronization/yield.cc",
            "src/external/webrtc/rtc_base/synchronization/yield.h",
            "src/external/webrtc/rtc_base/system/arch.h",
            "src/external/webrtc/rtc_base/system/file_wrapper.cc",
            "src/external/webrtc/rtc_base/system/file_wrapper.h",
            "src/external/webrtc/rtc_base/system/inline.h",
            "src/external/webrtc/rtc_base/system/rtc_export.h",
            "src/external/webrtc/rtc_base/system/unused.h",
            "src/external/webrtc/rtc_base/system/warn_current_thread_is_deadlocked.h",
            "src/external/webrtc/rtc_base/task_utils/pending_task_safety_flag.cc",
            "src/external/webrtc/rtc_base/task_utils/pending_task_safety_flag.h",
            "src/external/webrtc/rtc_base/task_utils/to_queued_task.h",
            "src/external/webrtc/rtc_base/third_party/base64/base64.cc",
            "src/external/webrtc/rtc_base/third_party/base64/base64.h",
            "src/external/webrtc/rtc_base/third_party/sigslot/sigslot.cc",
            "src/external/webrtc/rtc_base/third_party/sigslot/sigslot.h",
            "src/external/webrtc/rtc_base/thread_annotations.h",
            "src/external/webrtc/rtc_base/thread_checker.h",
            "src/external/webrtc/rtc_base/thread_message.h",
            "src/external/webrtc/rtc_base/thread.cc",
            "src/external/webrtc/rtc_base/thread.h",
            "src/external/webrtc/rtc_base/time_utils.cc",
            "src/external/webrtc/rtc_base/time_utils.h",
            "src/external/webrtc/rtc_base/trace_event.h",
            "src/external/webrtc/rtc_base/type_traits.h",
            "src/external/webrtc/rtc_base/unique_id_generator.cc",
            "src/external/webrtc/rtc_base/unique_id_generator.h",
            "src/external/webrtc/rtc_base/units/unit_base.h",
            "src/external/webrtc/rtc_base/weak_ptr.cc",
            "src/external/webrtc/rtc_base/weak_ptr.h",
            "src/external/webrtc/rtc_base/zero_memory.cc",
            "src/external/webrtc/rtc_base/zero_memory.h",
            "src/external/webrtc/system_wrappers/include/clock.h",
            "src/external/webrtc/system_wrappers/include/field_trial.h",
            "src/external/webrtc/system_wrappers/include/metrics.h",
            "src/external/webrtc/system_wrappers/include/ntp_time.h",
            "src/external/webrtc/system_wrappers/source/clock.cc",
            "src/external/webrtc/system_wrappers/source/field_trial.cc",
            "src/external/webrtc/system_wrappers/source/metrics.cc"
        }
        for _, v in ipairs(files) do
            if v:endswith(".cc") then
                add_files(v)
            end
            if v:endswith(".h") then
                add_headerfiles(v)
            end
        end
        if is_plat("windows") then
            add_files(
                "src/external/webrtc/rtc_base/win32.cc",
                "src/external/webrtc/rtc_base/synchronization/rw_lock_win.cc"
            )
            add_headerfiles(
                "src/external/webrtc/rtc_base/win32.h",
                "src/external/webrtc/rtc_base/synchronization/rw_lock_win.h"
            )
            on_config(function(target)
                io.writefile("src/external/webrtc/base/third_party/libevent/event.h", "#pragma once\n#include <event.h>\n")
            end)
            add_syslinks("ws2_32", "crypt32", "winmm", "Secur32", "Iphlpapi")
        else
            add_files(
                "src/external/webrtc/rtc_base/synchronization/rw_lock_posix.cc",
                "src/external/webrtc/rtc_base/ifaddrs_converter.cc"
            )
            add_headerfiles(
                "src/external/webrtc/rtc_base/synchronization/rw_lock_posix.h"
            )
            add_syslinks("pthread")
            add_cxflags("-Wno-attributes")
        end
        set_languages("cxx17")
        add_packages("openssl", "abseil")
        add_includedirs("src/external/webrtc")

    target("steamwebrtc")
        set_kind("static")
        add_rules("c++")
        if is_plat("windows") then
            add_defines("WEBRTC_WIN", "NOMINMAX", "WIN32_LEAN_AND_MEAN", "_WINSOCKAPI_")
            add_cxflags("/wd4715", "/wd4005", "/wd4996", "/wd4530")
        else
            add_ldflags("-Wl", "--no-undefined")
            add_defines("WEBRTC_POSIX", "WEBRTC_LINUX")
        end
        add_files("src/external/steamwebrtc/ice_session.cpp")
        add_includedirs("src/external/webrtc")
        set_languages("cxx17")
        add_deps("webrtc-lite")
        add_packages("abseil")
end

target("gns") -- we need limit path length
    set_kind("$(kind)")
    add_rules("protobuf.cpp")
    set_languages("gnu17", "gnu++17")
    add_vectorexts("sse2")
    add_packages("protobuf-cpp")
    set_basename("gamenetworkingsockets")

    if is_plat("windows") then
        add_syslinks("ws2_32", "Bcrypt")
        add_defines("WIN32", "_WINDOWS")
    else
        add_packages("openssl")
        add_syslinks("pthread")
        add_defines("POSIX", "LINUX", "GNUC", "GNU_COMPILER")
    end

    if has_config("webrtc") then
        add_defines("STEAMWEBRTC_USE_STATIC_LIBS", "STEAMNETWORKINGSOCKETS_ENABLE_ICE")
        add_deps("steamwebrtc")
        add_packages("abseil")
    end

    if is_kind("shared") then
        add_defines("STEAMNETWORKINGSOCKETS_FOREXPORT")
    else
        add_defines("STEAMNETWORKINGSOCKETS_STATIC_LINK")
        if not is_plat("windows") then
            add_defines("OPENSSL_USE_STATIC_LIBS")
        end
    end

    add_includedirs("include",
                    "src",
                    "src/common",
                    "src/tier0",
                    "src/tier1",
                    "src/vstdlib",
                    "src/steamnetworkingsockets",
                    "src/steamnetworkingsockets/clientlib",
                    "src/public")

    add_headerfiles("include/(steam/*.h)")
    add_headerfiles("include/(minbase/*.h)")
    add_headerfiles("src/public/(*/*.h)")

    add_defines("VALVE_CRYPTO_ENABLE_25519",
                "GOOGLE_PROTOBUF_NO_RTTI",
                "CRYPTO_DISABLE_ENCRYPT_WITH_PASSWORD")

    -- Crypto specific files
    if is_plat("windows") then
        add_files("src/common/crypto_bcrypt.cpp",
                  "src/common/crypto_25519_donna.cpp",
                  "src/external/curve25519-donna/curve25519.c",
                  "src/external/curve25519-donna/curve25519_VALVE_sse2.c",
                  "src/external/ed25519-donna/ed25519_VALVE.c",
                  "src/external/ed25519-donna/ed25519_VALVE_sse2.c")

        add_defines("ED25519_HASH_BCRYPT",
                    "VALVE_CRYPTO_25519_DONNA",
                    "VALVE_CRYPTO_BCRYPT",
                    "STEAMNETWORKINGSOCKETS_CRYPTO_BCRYPT")
    else
        add_files("src/common/crypto_openssl.cpp",
                  "src/common/crypto_25519_openssl.cpp",
                  "src/common/opensslwrapper.cpp")

        add_defines("VALVE_CRYPTO_25519_OPENSSL",
                    "VALVE_CRYPTO_25519_OPENSSLEVP",
                    "VALVE_CRYPTO_OPENSSL",
                    "ENABLE_OPENSSLCONNECTION",
                    "STEAMNETWORKINGSOCKETS_CRYPTO_VALVEOPENSSL")
    end

    add_files("src/common/steamnetworkingsockets_messages_certs.proto",
              "src/common/steamnetworkingsockets_messages.proto",
              "src/common/steamnetworkingsockets_messages_udp.proto")

    add_files("src/common/crypto.cpp",
              "src/common/crypto_textencode.cpp",
              "src/common/keypair.cpp",
              "src/common/steamid.cpp",
              "src/vstdlib/strtools.cpp",
              "src/tier0/dbg.cpp",
              "src/tier0/platformtime.cpp",
              "src/tier1/ipv6text.c",
              "src/tier1/netadr.cpp",
              "src/tier1/utlbuffer.cpp",
              "src/tier1/utlmemory.cpp",
              "src/steamnetworkingsockets/steamnetworkingsockets_certs.cpp",
              "src/steamnetworkingsockets/steamnetworkingsockets_thinker.cpp",
              "src/steamnetworkingsockets/steamnetworkingsockets_certstore.cpp",
              "src/steamnetworkingsockets/clientlib/steamnetworkingsockets_connections.cpp",
              "src/steamnetworkingsockets/clientlib/steamnetworkingsockets_flat.cpp",
              "src/steamnetworkingsockets/clientlib/steamnetworkingsockets_lowlevel.cpp",
              "src/steamnetworkingsockets/steamnetworkingsockets_shared.cpp",
              "src/steamnetworkingsockets/steamnetworkingsockets_stats.cpp",
              "src/steamnetworkingsockets/clientlib/steamnetworkingsockets_snp.cpp",
              "src/steamnetworkingsockets/clientlib/steamnetworkingsockets_udp.cpp",
              "src/steamnetworkingsockets/clientlib/csteamnetworkingmessages.cpp",
              "src/steamnetworkingsockets/clientlib/csteamnetworkingsockets.cpp",
              "src/steamnetworkingsockets/clientlib/steamnetworkingsockets_p2p.cpp",
              "src/steamnetworkingsockets/clientlib/steamnetworkingsockets_stun.cpp",
              "src/steamnetworkingsockets/clientlib/steamnetworkingsockets_p2p_ice.cpp")
