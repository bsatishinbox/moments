package io.github.bsatishinbox.moment

import org.junit.Assert.*
import org.junit.Test
import java.time.ZonedDateTime

class LifeSettingsTest {
    private val now=ZonedDateTime.parse("2026-10-07T12:00:00Z").toInstant().toEpochMilli()
    @Test fun milestoneChangeKeepsAnchor() {
        val initial=LifeSettings.initial(now)
        val changed=initial.updated(37,70,null,now+86_400_000)
        assertEquals(initial.bornAt,changed.bornAt)
        assertEquals(LifeSettings.addYears(initial.bornAt,70),changed.targetAt)
    }
    @Test fun disablingBirthdayCreatesAgeOnlyAnchor() {
        val exact=LifeSettings.initial(now).updated(37,60,"1989-01-01",now)
        val changed=exact.updated(exact.age(now),60,null,now)
        assertFalse(changed.exactBirthday)
        assertEquals(LifeSettings.addYears(now,-37),changed.bornAt)
    }
    @Test fun expiresWithoutGoingNegative() {
        val initial=LifeSettings.initial(now)
        assertEquals(0L,initial.total(TimeUnit.MINUTES,initial.targetAt+1000))
    }
    @Test(expected=IllegalArgumentException::class) fun rejectsMilestoneBeforeCurrentAge() {
        LifeSettings.initial(now).updated(37,36,null,now)
    }
}
