from importlib.metadata import PackageNotFoundError, version

try:
    __version__ = version("aiohttp-jwt")
except PackageNotFoundError:  # pragma: no cover
    __version__ = "unknown"

from .middleware import JWTMiddleware
from .permissions import check_permissions, login_required, match_all, match_any

__all__ = (
    "__version__",
    "JWTMiddleware",
    "check_permissions",
    "login_required",
    "match_any",
    "match_all",
)
