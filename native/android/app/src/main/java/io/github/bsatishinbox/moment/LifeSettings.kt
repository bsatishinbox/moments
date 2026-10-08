package io.github.bsatishinbox.moment

import java.time.Instant
import java.time.LocalDate
import java.time.ZoneId

enum class TimeUnit(val title: String, val millis: Long) {
    DAYS("Days", 86_400_000), HOURS("Hours", 3_600_000), MINUTES("Minutes", 60_000)
}

data class LifeSettings(
    val bornAt: Long, val targetAt: Long, val targetAge: Int = 60,
    val exactBirthday: Boolean = false, val unit: TimeUnit = TimeUnit.DAYS
) {
    fun age(now: Long = System.currentTimeMillis()): Int {
        val zone = ZoneId.systemDefault()
        var years = Instant.ofEpochMilli(now).atZone(zone).year - Instant.ofEpochMilli(bornAt).atZone(zone).year
        if (now < addYears(bornAt, years)) years--
        return years.coerceAtLeast(0)
    }
    fun remaining(now: Long): Long = (targetAt - now).coerceAtLeast(0)
    fun total(unit: TimeUnit, now: Long): Long = remaining(now) / unit.millis
    fun fraction(now: Long): Float = (remaining(now).toDouble() / (targetAt - bornAt).coerceAtLeast(1)).coerceIn(0.0,1.0).toFloat()
    fun valid(now: Long = System.currentTimeMillis()): Boolean = bornAt <= now && targetAt > bornAt && targetAge in 1..120 &&
        kotlin.math.abs(targetAt - addYears(bornAt,targetAge)) < 86_400_000
    fun updated(age: Int, target: Int, birthday: String?, now: Long = System.currentTimeMillis()): LifeSettings {
        require(age in 0..119 && target > age && target <= 120) { "Enter an age from 0 to 119 and a higher milestone, up to 120." }
        val birth = if (!birthday.isNullOrBlank()) {
            val date = runCatching { LocalDate.parse(birthday) }.getOrElse { throw IllegalArgumentException("Enter a valid birthday as YYYY-MM-DD.") }
            require(!date.isAfter(Instant.ofEpochMilli(now).atZone(ZoneId.systemDefault()).toLocalDate())) { "Choose a birthday in the past." }
            date.atStartOfDay(ZoneId.systemDefault()).toInstant().toEpochMilli()
        } else if (age != this.age(now) || exactBirthday) addYears(now, -age) else bornAt
        val next = copy(bornAt = birth, targetAt = addYears(birth,target), targetAge = target,
            exactBirthday = !birthday.isNullOrBlank())
        require(next.age(now) < target && next.age(now) < 120) { "Choose a milestone above your current age, up to 120." }
        return next
    }
    companion object {
        fun addYears(time: Long, years: Int): Long = Instant.ofEpochMilli(time).atZone(ZoneId.systemDefault()).plusYears(years.toLong()).toInstant().toEpochMilli()
        fun initial(now: Long = System.currentTimeMillis()): LifeSettings {
            val born = addYears(now, -37)
            return LifeSettings(born, addYears(born,60))
        }
    }
}
