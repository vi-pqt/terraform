"""
payment_consumer.py — Lambda handler for payment audit logging.

Session 11: SQS/SNS Messaging — CuliShop DevOps on AWS
Architecture: SQS FIFO Payment Queue → this Lambda (NO SNS fanout)
Messages arrive directly from the FIFO queue — no SNS envelope wrapper.
FIFO guarantees ordering and exactly-once delivery within a message group.

Idempotency note:
  In-memory set is used here for demo purposes only.
  In production, use DynamoDB conditional writes to store processed
  transaction IDs so the check survives Lambda container recycling.
"""

import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Lưu các transaction đã xử lý — chỉ dùng trong demo, không bền vững qua cold start
# Production: dùng DynamoDB với conditional write để đảm bảo idempotency thực sự
_processed_transactions: set = set()


def lambda_handler(event, context):
    """Consume payment audit events directly from SQS FIFO and log with idempotency check."""
    for record in event["Records"]:
        # FIFO queue gửi thẳng JSON body, không qua SNS envelope
        payment = json.loads(record["body"])

        order_id = payment["order_id"]
        transaction_id = payment["transaction_id"]
        total = payment.get("total", {})

        units = total.get("units", 0)
        currency_code = total.get("currency_code", "USD")

        # Kiểm tra idempotency trước khi xử lý
        if transaction_id in _processed_transactions:
            logger.info(
                f"[PAYMENT AUDIT] Duplicate detected for order {order_id} "
                f"(txn={transaction_id}), skipping"
            )
            continue

        _processed_transactions.add(transaction_id)
        logger.info(
            f"[PAYMENT AUDIT] Order {order_id}, txn={transaction_id}, "
            f"amount={units} {currency_code}"
        )

    return {"statusCode": 200}
