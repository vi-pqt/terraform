"""
inventory_consumer.py — Lambda handler for inventory stock updates.

Session 11: SQS/SNS Messaging — CuliShop DevOps on AWS
Architecture: SNS Order Topic → SQS Inventory Queue → this Lambda
The SQS message body is an SNS envelope JSON; the actual order payload
lives in envelope["Message"] as a JSON string.
"""

import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    """Consume order events from SQS (via SNS fanout) and log inventory deductions."""
    for record in event["Records"]:
        # SQS message body là SNS envelope JSON
        sns_envelope = json.loads(record["body"])
        # Payload thực sự nằm trong trường "Message" của SNS envelope
        order = json.loads(sns_envelope["Message"])

        order_id = order["order_id"]
        items = order.get("items", [])

        logger.info(f"[INVENTORY] Updating stock for order {order_id}")

        # Ghi log từng sản phẩm cần giảm tồn kho
        for item in items:
            product_id = item.get("product_id", "?")
            quantity = item.get("quantity", 0)
            logger.info(f"[INVENTORY] Product {product_id}: -{quantity}")

    return {"statusCode": 200}
