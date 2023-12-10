from models import BaseModel

from utils.snowflake import Snowflake


class Challenge(BaseModel):
    id: Snowflake
    number: int | None
    author_id: Snowflake
    title: str
    slug: str
    difficulty: int | None
    labels: list[str]
    description: str
    task: str
    example_input: str
    example_output: str
    notes: str
    released_at: Snowflake | None
    deleted: bool = False
