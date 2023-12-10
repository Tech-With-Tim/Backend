from models import BaseModel

from utils.snowflake import Snowflake


class User(BaseModel):
    id: Snowflake
    username: str
