"""
email_consumer.py — Lambda handler for order confirmation emails.

Session 11: SQS/SNS Messaging — CuliShop DevOps on AWS
Architecture: SNS Order Topic → SQS Email Queue → this Lambda
The SQS message body is an SNS envelope JSON; the actual order payload
lives in envelope["Message"] as a JSON string.
"""

import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    """Consume order events from SQS (via SNS fanout) and log email confirmation."""
    for record in event["Records"]:
        # SQS message body là SNS envelope JSON
        sns_envelope = json.loads(record["body"])
        # Payload thực sự nằm trong trường "Message" của SNS envelope
        order = json.loads(sns_envelope["Message"])

        order_id = order["order_id"]
        email = order["email"]
        items = order.get("items", [])
        total = order.get("total", {})

        item_names = ", ".join(item.get("name", item.get("product_id", "?")) for item in items)
        units = total.get("units", 0)
        currency_code = total.get("currency_code", "USD")

        logger.info(f"[EMAIL] Sending confirmation to {email} for order {order_id}")
        logger.info(f"[EMAIL] Items: {item_names} | Total: {units} {currency_code}")

    return {"statusCode": 200}
