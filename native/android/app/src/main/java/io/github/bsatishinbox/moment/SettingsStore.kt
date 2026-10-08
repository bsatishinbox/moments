package io.github.bsatishinbox.moment

import android.content.Context
import org.json.JSONObject

class SettingsStore(context: Context) {
    private val prefs = context.getSharedPreferences("moment", Context.MODE_PRIVATE)
    fun read(): LifeSettings {
        val settings = runCatching {
            val json = JSONObject(prefs.getString("timeline", null) ?: error("No timeline"))
            LifeSettings(json.getLong("bornAt"), json.getLong("targetAt"), json.getInt("targetAge"),
                json.getBoolean("exactBirthday"), TimeUnit.valueOf(json.getString("unit")))
                .also { require(it.valid()) }
        }.getOrElse { LifeSettings.initial() }
        save(settings)
        return settings
    }
    fun save(value: LifeSettings) {
        val json = JSONObject().put("bornAt",value.bornAt).put("targetAt",value.targetAt)
            .put("targetAge",value.targetAge).put("exactBirthday",value.exactBirthday).put("unit",value.unit.name)
        prefs.edit().putString("timeline",json.toString()).apply()
    }
}
