package io.github.bsatishinbox.moment

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Settings
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.semantics.*
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.compose.LocalLifecycleOwner
import androidx.lifecycle.repeatOnLifecycle
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import java.text.NumberFormat
import java.time.Instant
import java.time.LocalDate
import java.time.ZoneId
import java.time.format.DateTimeFormatter
import java.time.format.FormatStyle
import java.util.Locale

private val Background = Color(0xFFF7F8F4)
private val Ink = Color(0xFF19221B)
private val Muted = Color(0xFF626D63)
private val Line = Color(0xFFE1E6DC)
private val Accent = Color(0xFFC6E59D)
private val Green = Color(0xFF486A30)
private fun number(value: Long) = NumberFormat.getIntegerInstance().format(value)

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        val store = SettingsStore(this)
        setContent {
            MaterialTheme(colorScheme = lightColorScheme(primary = Green, onPrimary = Color.White,
                background = Background, surface = Background, onSurface = Ink, onBackground = Ink)) {
                MomentApp(store)
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun MomentApp(store: SettingsStore) {
    var settings by remember { mutableStateOf(store.read()) }
    var now by remember { mutableLongStateOf(System.currentTimeMillis()) }
    var editing by rememberSaveable { mutableStateOf(false) }
    val owner = LocalLifecycleOwner.current
    LaunchedEffect(owner) {
        owner.lifecycle.repeatOnLifecycle(Lifecycle.State.STARTED) {
            while (isActive) { now = System.currentTimeMillis(); delay(1000) }
        }
    }
    fun save(next: LifeSettings) { store.save(next); settings = next }
    Surface(modifier = Modifier.fillMaxSize(), color = Background) {
        Column(Modifier.fillMaxSize().safeDrawingPadding().verticalScroll(rememberScrollState()).padding(horizontal = 24.dp, vertical = 20.dp), horizontalAlignment = Alignment.CenterHorizontally) {
            Column(Modifier.widthIn(max = 500.dp).fillMaxWidth(), horizontalAlignment = Alignment.CenterHorizontally) {
                Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                    Text("moment.", fontSize = 27.sp, fontWeight = FontWeight.SemiBold, letterSpacing = (-1).sp)
                    Spacer(Modifier.weight(1f))
                    IconButton(onClick = { editing = true }, modifier = Modifier.border(1.dp, Line, CircleShape)) {
                        Icon(Icons.Outlined.Settings, contentDescription = "Open settings", tint = Ink)
                    }
                }
                Spacer(Modifier.height(34.dp))
                Text("A LITTLE PERSPECTIVE", fontSize = 11.sp, letterSpacing = 2.sp, color = Muted, fontWeight = FontWeight.SemiBold)
                Spacer(Modifier.height(10.dp))
                Text("Time ahead.", fontSize = 39.sp, letterSpacing = (-1).sp)
                Spacer(Modifier.height(18.dp))
                TextButton(onClick = { editing = true }, colors = ButtonDefaults.textButtonColors(containerColor = Line.copy(alpha = .5f), contentColor = Ink)) {
                    Text("Age ${settings.age(now)}   —   Milestone ${settings.targetAge}", modifier = Modifier.padding(horizontal = 10.dp))
                }
                Spacer(Modifier.height(28.dp))
                Clock(settings, now)
                Spacer(Modifier.height(26.dp))
                Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    TimeUnit.entries.forEach { unit ->
                        val active = settings.unit == unit
                        val value = number(settings.total(unit,now))
                        BoxWithConstraints(Modifier.weight(1f).clip(RoundedCornerShape(15.dp))
                            .background(if(active) Accent else Color.Transparent)
                            .border(1.dp, if(active) Accent else Line,RoundedCornerShape(15.dp))
                            .clickable { save(settings.copy(unit=unit)) }
                            .semantics { role = Role.Tab; selected = active; contentDescription = "$value total ${unit.title.lowercase()}" }
                            .padding(horizontal = 11.dp, vertical = 15.dp)) {
                            val valueSize = (maxWidth.value / (value.length * .62f)).coerceAtMost(20f).sp
                            Column(verticalArrangement = Arrangement.spacedBy(9.dp)) {
                                Text(unit.title,fontSize=13.sp,color=Muted)
                                Text(value,fontSize=valueSize,fontWeight=FontWeight.Medium,maxLines=1)
                                Box(Modifier.size(14.dp,2.dp).background(if(active) Green else Color.Transparent,CircleShape))
                            }
                        }
                    }
                }
                Spacer(Modifier.height(17.dp))
                Row(Modifier.fillMaxWidth(),horizontalArrangement=Arrangement.SpaceBetween) {
                    Text("Time ahead",fontSize=11.sp,color=Muted)
                    val date=Instant.ofEpochMilli(settings.targetAt).atZone(ZoneId.systemDefault()).format(DateTimeFormatter.ofLocalizedDate(FormatStyle.MEDIUM))
                    Text((if(settings.exactBirthday) "Until " else "Approx. ")+date,fontSize=11.sp,color=Muted)
                }
                if(settings.remaining(now)==0L) { Text("You’ve reached this milestone. Choose your next one in settings.",fontSize=14.sp,textAlign=TextAlign.Center,modifier=Modifier.padding(top=22.dp)) }
                Spacer(Modifier.height(33.dp))
                Text("A milestone you choose. Not a prediction.",fontSize=13.sp,color=Muted,textAlign=TextAlign.Center)
                Spacer(Modifier.height(40.dp))
                Text("MAKE TODAY COUNT",fontSize=10.sp,letterSpacing=2.sp,color=Muted)
            }
        }
        if(editing) {
            ModalBottomSheet(onDismissRequest={editing=false},containerColor=Background) {
                SettingsSheet(settings,onCancel={editing=false},onSave={save(it);editing=false})
            }
        }
    }
}

@Composable
private fun Clock(settings: LifeSettings, now: Long) {
    val total=number(settings.total(settings.unit,now))
    Box(Modifier.sizeIn(maxWidth=324.dp,maxHeight=324.dp).fillMaxWidth().aspectRatio(1f)
        .semantics(mergeDescendants = true) { contentDescription="$total ${settings.unit.title.lowercase()} remaining to age ${settings.targetAge}" },contentAlignment=Alignment.Center) {
        Canvas(Modifier.fillMaxSize().padding(5.dp)) {
            val stroke=5.dp.toPx()
            drawCircle(Line,style=Stroke(stroke))
            drawArc(Green,-90f,360f*settings.fraction(now),false,topLeft=Offset.Zero,size=Size(size.width,size.height),style=Stroke(stroke,cap=StrokeCap.Round))
        }
        Column(Modifier.padding(25.dp),horizontalAlignment=Alignment.CenterHorizontally) {
            Text("YOURS TO LIVE",fontSize=11.sp,letterSpacing=1.8.sp,color=Muted,fontWeight=FontWeight.SemiBold)
            Spacer(Modifier.height(11.dp))
            Text(total,fontSize=(if(total.length>9) 34 else if(total.length>6) 46 else 61).sp,fontWeight=FontWeight.Normal,letterSpacing=(-1.5).sp,maxLines=1)
            Text("${settings.unit.title.lowercase()} ahead",fontSize=17.sp,color=Muted)
            Spacer(Modifier.height(19.dp))
            Box(Modifier.size(30.dp,1.dp).background(Line))
            Spacer(Modifier.height(14.dp))
            Text(String.format(Locale.getDefault(),"%.1f%% of your timeline",settings.fraction(now)*100),fontSize=12.sp,color=Muted)
        }
    }
}

@Composable
private fun SettingsSheet(settings:LifeSettings,onCancel:()->Unit,onSave:(LifeSettings)->Unit) {
    var age by rememberSaveable { mutableStateOf(settings.age().toString()) }
    var target by rememberSaveable { mutableStateOf(settings.targetAge.toString()) }
    var useBirthday by rememberSaveable { mutableStateOf(settings.exactBirthday) }
    var birthday by rememberSaveable { mutableStateOf(Instant.ofEpochMilli(settings.bornAt).atZone(ZoneId.systemDefault()).toLocalDate().toString()) }
    var error by remember { mutableStateOf<String?>(null) }
    Column(Modifier.fillMaxWidth().imePadding().verticalScroll(rememberScrollState()).padding(start=24.dp,end=24.dp,bottom=32.dp),verticalArrangement=Arrangement.spacedBy(16.dp)) {
        Text("YOUR TIMELINE",fontSize=11.sp,letterSpacing=2.sp,color=Muted)
        Text("Make it yours.",fontSize=29.sp)
        OutlinedTextField(age,{age=it},label={Text("Your age")},keyboardOptions=KeyboardOptions(keyboardType=KeyboardType.Number),singleLine=true,enabled=!useBirthday,modifier=Modifier.fillMaxWidth())
        OutlinedTextField(target,{target=it},label={Text("Your milestone")},keyboardOptions=KeyboardOptions(keyboardType=KeyboardType.Number),singleLine=true,modifier=Modifier.fillMaxWidth())
        Row(horizontalArrangement=Arrangement.spacedBy(8.dp)) {
            listOf(60,70,80,90).forEach { value ->
                FilterChip(selected=target==value.toString(),onClick={target=value.toString()},label={Text("$value")},modifier=Modifier.weight(1f))
            }
        }
        Row(verticalAlignment=Alignment.CenterVertically) {
            Text("Use my birthday",modifier=Modifier.weight(1f))
            Switch(checked=useBirthday,onCheckedChange={useBirthday=it})
        }
        if(useBirthday) {
            OutlinedTextField(birthday,{ value ->
                birthday=value
                runCatching { LocalDate.parse(value).atStartOfDay(ZoneId.systemDefault()).toInstant().toEpochMilli() }
                    .onSuccess { age=settings.copy(bornAt=it).age().toString() }
            },label={Text("Birthday (YYYY-MM-DD)")},singleLine=true,modifier=Modifier.fillMaxWidth())
        }
        Text("With age only, we start as if your birthday is today. Add your birthday for an exact calendar countdown.",fontSize=13.sp,color=Muted)
        error?.let { Text(it,color=MaterialTheme.colorScheme.error,fontSize=14.sp,modifier=Modifier.semantics{liveRegion=LiveRegionMode.Polite}) }
        Button(onClick={
            try {
                val current=age.toIntOrNull()?:throw IllegalArgumentException("Enter your age as a whole number.")
                val milestone=target.toIntOrNull()?:throw IllegalArgumentException("Enter a milestone as a whole number.")
                if(useBirthday && birthday.isBlank())throw IllegalArgumentException("Enter your birthday.")
                onSave(settings.updated(current,milestone,if(useBirthday)birthday else null))
            }catch(e:IllegalArgumentException){error=e.message}
        },modifier=Modifier.fillMaxWidth().heightIn(min=52.dp),colors=ButtonDefaults.buttonColors(containerColor=Ink)) {Text("Save my timeline")}
        TextButton(onClick=onCancel,modifier=Modifier.align(Alignment.CenterHorizontally)){Text("Cancel")}
        Text("Saved on this device. No account needed.",fontSize=12.sp,color=Muted,modifier=Modifier.align(Alignment.CenterHorizontally))
    }
}
