from litellm.integrations.custom_logger import CustomLogger
import litellm
from litellm.proxy.proxy_server import UserAPIKeyAuth, DualCache
from litellm.types.utils import ModelResponseStream
from typing import Any, AsyncGenerator, Optional, Literal


# This file includes the custom callbacks for LiteLLM Proxy
# Once defined, these can be passed in proxy_config.yaml
class MyCustomHandler(CustomLogger):  # https://docs.litellm.ai/docs/observability/custom_callback#callback-class
    # Class variables or attributes
    def __init__(self):
        pass

    #### CALL HOOKS - proxy only #### 

    async def async_pre_call_hook(self, user_api_key_dict: UserAPIKeyAuth, cache: DualCache, data: dict,
                                  call_type: Literal[
                                      "completion",
                                      "text_completion",
                                      "embeddings",
                                      "image_generation",
                                      "moderation",
                                      "audio_transcription",
                                  ]):
        pass

    async def async_post_call_failure_hook(
            self,
            request_data: dict,
            original_exception: Exception,
            user_api_key_dict: UserAPIKeyAuth,
            traceback_str: Optional[str] = None,
    ) -> Optional[HTTPException]:
        """
        Transform error responses sent to clients.

        Return an HTTPException to replace the original error with a user-friendly message.
        Return None to use the original exception.

        Example:
            if isinstance(original_exception, litellm.ContextWindowExceededError):
                return HTTPException(
                    status_code=400,
                    detail="Your prompt is too long. Please reduce the length and try again."
                )
            return None  # Use original exception
        """
        pass

    async def async_post_call_success_hook(
            self,
            data: dict,
            user_api_key_dict: UserAPIKeyAuth,
            response,
    ):
        pass

    async def async_moderation_hook(  # call made in parallel to llm api call
            self,
            data: dict,
            user_api_key_dict: UserAPIKeyAuth,
            call_type: Literal["completion", "embeddings", "image_generation", "moderation", "audio_transcription"],
    ):
        pass

    async def async_post_call_streaming_hook(
            self,
            user_api_key_dict: UserAPIKeyAuth,
            response: str,
    ):
        pass

    async def async_post_call_streaming_iterator_hook(
            self,
            user_api_key_dict: UserAPIKeyAuth,
            response: Any,
            request_data: dict,
    ) -> AsyncGenerator[ModelResponseStream, None]:
        """
        Passes the entire stream to the guardrail

        This is useful for plugins that need to see the entire stream.
        """
        pass

    async def async_post_call_response_headers_hook(
            self,
            data: dict,
            user_api_key_dict: UserAPIKeyAuth,
            response: Any,
            request_headers: Optional[Dict[str, str]] = None,
    ) -> Optional[Dict[str, str]]:
        """
        Inject custom headers into HTTP response (runs for both success and failure).
        """
        pass


proxy_handler_instance = MyCustomHandler()