package com.follow.clash.service.models

import com.follow.clash.common.formatBytes

data class Traffic(
    val up: Long,
    val down: Long,
)

val Traffic.speedText: String
    get() = "${up.formatBytes}/s↑  ${down.formatBytes}/s↓"
