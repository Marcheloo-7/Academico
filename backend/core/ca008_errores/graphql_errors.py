import strawberry

from .logging_config import logger


class AcademicoSchema(strawberry.Schema):
    def process_errors(self, errors, execution_context=None):
        for error in errors:
            logger.error("Error GraphQL: %s", error)
        super().process_errors(errors, execution_context)
