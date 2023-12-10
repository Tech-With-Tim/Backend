from __future__ import annotations

from datetime import datetime


class Snowflake(int):
    """
    Basic Snowflake ID implementation.

    More information about snowflakes here:
        https://www.wikihero.net/en/Snowflake_ID
    """

    class Epoch:
        TWT = 1539539800000
        DISCORD = 1420070400000

    def timestamp(self, from_epoch: int = Epoch.TWT) -> int:
        """Converts the Snowflake ID to a unix timestamp."""
        return int(((self >> 22) + from_epoch) / 1000)

    def datetime(self, from_epoch: int = Epoch.TWT) -> datetime:
        """
        Converts the Snowflake ID to a `datetime` object.
        """
        return datetime.utcfromtimestamp(self.timestamp(from_epoch=from_epoch))
