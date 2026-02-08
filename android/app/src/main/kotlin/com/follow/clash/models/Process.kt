package com.follow.clash.models

data class Metadata(
    val protocol: Int,
    val sourceIp: String,
    val sourcePort: Int,
    val targetIp: String,
    val targetPort: Int,
    val uid: Int,
)

data class Process(
    val id: String,
    val metadata: Metadata,
)
