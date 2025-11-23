"""
Type definitions using TypedDict for better type safety
"""

from typing import TypedDict


class DocumentMetadataDict(TypedDict, total=False):
    """Metadata structure for documents"""

    doctor_name: str | None
    doctor_specialty: str | None
    document_date: str | None
    exam_type: str | None
    document_type: str | None
    keywords: list[str]
    extracted_text: str


class DocumentResultDict(TypedDict):
    """Result structure from PDF processing"""

    filename: str
    original_name: str
    file_path: str
    file_size: int
    text_content: str


class PatternDict(TypedDict, total=False):
    """Pattern detection result structure"""

    type: str
    description: str
    confidence: float
    frequency: str | None
    trend: str | None


class HealthMetricsDict(TypedDict, total=False):
    """Health metrics structure from ARIA"""

    average_pain_level: float
    pain_frequency: str
    pain_duration: str
    triggers: list[str]
    patterns: list[PatternDict]


class ChatResponseDict(TypedDict, total=False):
    """Chat response structure"""

    answer: str
    related_documents: list[int]
    suggestions: list[str]
    patterns_detected: PatternDict | None
    question_type: str | None
