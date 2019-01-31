import asyncio
import re

from aiohttp.hdrs import METH_OPTIONS


def check_request(request, entries):
    if request.method == METH_OPTIONS:
        return True
    for pattern in entries:
        if re.match(pattern, request.path):
            return True

    return False


async def invoke(func):
    result = func()
    if asyncio.iscoroutine(result):
        result = await result
    return result
