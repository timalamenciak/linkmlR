from __future__ import annotations

import json
from typing import Any, Dict, Optional
from linkml.validator.report import ValidationReport


def _load_data_guess(text: str) -> Any:
    """Parse JSON passed from R."""
    return json.loads(text)


def validate_json_instance(
    schema_path: str,
    instance_json: str,
    target_class: Optional[str] = None,
) -> Dict[str, Any]:
    """
    Validate a JSON instance against a LinkML schema.

    Returns:
      dict with keys:
        - ok: bool
        - issues: list
    """
    try:
        data = _load_data_guess(instance_json)
    except Exception as e:
        return {
            "ok": False,
            "issues": [{"message": "Failed to parse instance JSON", "error": str(e)}],
        }

    try:
        from linkml.validator import Validator
    except Exception as e:
        return {
            "ok": False,
            "issues": [{"message": "Could not import linkml.validator.Validator", "error": str(e)}],
        }

    try:
        # Most compatible constructor across LinkML versions
        v = Validator(schema_path)

        if target_class:
            result = v.validate(data, target_class=target_class)
        else:
            result = v.validate(data)

    except Exception as e:
        return {
            "ok": False,
            "issues": [{"message": "Validation failed", "error": str(e)}],
        }

   # Normalize result

    if isinstance(result, ValidationReport):
        issues = list(result.results)
        ok = len(issues) == 0

    elif hasattr(result, "issues"):
        issues = list(result.issues)
        ok = len(issues) == 0
    elif isinstance(result, bool):
        ok = result
        issues = []

    else:
        ok = False
        issues = [{
            "message": "Unknown validator result type",
            "result": str(result),
            "type": str(type(result)),
        }]

    return {"ok": ok, "issues": issues}
