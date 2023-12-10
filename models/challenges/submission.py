from models import BaseModel

from utils.snowflake import Snowflake


class Submission(BaseModel):
    id: Snowflake
    solution: str
    author_id: Snowflake
    challenge_id: Snowflake
    language_id: Snowflake
