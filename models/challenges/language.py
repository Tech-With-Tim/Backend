from models import BaseModel

from utils.snowflake import Snowflake


class ChallengeLanguage(BaseModel):
    id: Snowflake
    name: str
    download_url: str
    enabled: bool
