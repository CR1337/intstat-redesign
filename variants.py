from dataclasses import dataclass
from typing import List


@dataclass
class Variant:
    name: str
    short_name: str
    user_tracking: bool

    def __hash__(self) -> int:
        return (
            hash(self.name) 
            ^ hash(self.short_name)
            ^ hash(self.user_tracking)
        )

VARIANTS: List[Variant] = [
    Variant("with_tracking", "wt", True),
    Variant("without_tracking", "wot", False)
]