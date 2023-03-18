#
#  _    ___  ___ ___  _  _ ___ _____    _   _ ___ ___ ___ ___  ___ _____
# | |  / _ \| _ \   \| \| | __|_   _|__| | | / __| __| _ \ _ )/ _ \_   _|
# | |_| (_) |   / |) | .` | _|  | ||___| |_| \__ \ _||   / _ \ (_) || |
# |____\___/|_|_\___/|_|\_|___| |_|     \___/|___/___|_|_\___/\___/ |_|
#
#                            © Copyright 2022
#
#                       https://t.me/lordnet_userbot
#
# 🔒 Licensed under the GNU GPLv3
# 🌐 https://www.gnu.org/licenses/agpl-3.0.html

import inspect
from pyrogram.errors import RPCError
from pyrogram.types import Message

from helper.cmd import get_module_name, exception_str


async def error_handler_async(_, error: Exception, message: Message):
    txt = get_error(error, message)
    try:
        return await message.edit(txt)
    except RPCError as ex:
        name = ex.ID or ex.NAME
        if name in ["MSG_ID_INVALID", "MESSAGE_ID_INVALID"]:
            try:
                return await message.reply(text=txt)
            except RPCError:
                return


def get_error(error: Exception, message: Message):
    trace = inspect.trace()
    try:
        name = get_module_name(inspect.getmodule(trace[-1][0]))
        args = (
            error,
            name,
            trace[-1][2],
            " ".join(message.command),
        )
    except AttributeError:
        args = (
            error,
            "Unknown",
            trace[-1][2],
            " ".join(message.command),
        )
    except TypeError:
        args = (
            error,
            get_module_name(inspect.getmodule(trace[-1][0])),
            trace[-1][2],
            "",
        )
    except Exception:
        args = (error, "Unknown", 0, "Unknown")
    txt = exception_str(*args)
    return txt


def error_handler_sync(_, error: Exception, message: Message):
    txt = get_error(error, message)
    try:
        return message.edit(txt)
    except RPCError as ex:
        name = ex.ID or ex.NAME
        if name in ["MSG_ID_INVALID", "MESSAGE_ID_INVALID"]:
            try:
                return message.reply(text=txt)
            except RPCError:
                return
