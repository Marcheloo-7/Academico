from starlette.middleware.base import BaseHTTPMiddleware
import time

class LoggingMiddleware(BaseHTTPMiddleware):

    async def dispatch(self, request, call_next):
        start = time.time()

        response = await call_next(request)

        duration = time.time() - start

        print(
            f"{request.method} "
            f"{request.url.path} "
            f"{duration:.2f}s"
        )

        return response
