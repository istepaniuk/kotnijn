package com.istepaniuk.kotnijn

import com.rabbitmq.client.CancelCallback
import com.rabbitmq.client.ConnectionFactory
import com.rabbitmq.client.DeliverCallback
import com.rabbitmq.client.Delivery
import java.nio.charset.StandardCharsets

fun main() {
    println("Connecting...")
    val factory = ConnectionFactory()
    val connection = factory.newConnection("amqp://guest:guest@rabbitmq:5672/")
    val channel = connection.createChannel()

    channel.queueDeclare("some-queue", false, false, false, null)

    println("Waiting for messages...")
    val deliverCallback = DeliverCallback { _: String?, delivery: Delivery ->
        val message = String(delivery.body, StandardCharsets.UTF_8)
        println("Received: '$message'")
    }

    val cancelCallback = CancelCallback { consumerTag: String? ->
        println("Canceled!")
    }

    channel.basicConsume(
        "some-queue", true, "test-consumer", deliverCallback, cancelCallback
    )
}
