package com.kjxbyz.plugins.jpush

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.text.TextUtils
import android.util.Log
import com.fasterxml.jackson.core.type.TypeReference
import com.fasterxml.jackson.databind.ObjectMapper

public class OpenClickActivity : Activity() {

    /**消息Id */
    private val KEY_MSGID = "msg_id"

    /**该通知的下发通道 */
    private val KEY_WHICH_PUSH_SDK = "rom_type"

    /**通知标题 */
    private val KEY_TITLE = "n_title"

    /**通知内容 */
    private val KEY_CONTENT = "n_content"

    /**通知附加字段 */
    private val KEY_EXTRAS = "n_extras"

    protected override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.v(TAG, "[OpenClickActivity]: onCreate-----")
        handleOpenClick()
    }

    protected override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleOpenClick()
    }

    private fun handleOpenClick() {
        var data: String? = null
        //获取华为平台附带的jpush信息
        if (intent.data != null) {
            data = intent.data.toString()
        }

        //获取fcm、oppo、vivo、华硕、小米平台附带的jpush信息
        if (TextUtils.isEmpty(data) && intent.extras != null) {
            data = intent.extras?.getString("JMessageExtra")
        }
        Log.e(TAG, "handleOpenClick: $data")
        if (TextUtils.isEmpty(data)) return
        try {
            val objectMapper = ObjectMapper()
            val mapData = objectMapper.readValue(data, object : TypeReference<Map<String, Any?>?>() {})
            val title = mapData?.get(KEY_TITLE)
            val body = mapData?.get(KEY_CONTENT)
            val badge = mapData?.get("n_badge_add_num")
            val nExtras = mapData?.get(KEY_EXTRAS) as Map<String, Any?>?
            val templateKey = nExtras?.get("templateKey")
            val userId = nExtras?.get("userId")
            val bizSubName = nExtras?.get("bizSubName")
            val bizSubId = nExtras?.get("bizSubId")
            val expertsServiceId = nExtras?.get("expertsServiceId")
            val response: MutableMap<String, Any?> = HashMap()
            val extras: MutableMap<String, Any?> = HashMap()
            response["title"] = title
            response["body"] = body
            response["badge"] = badge
            extras["templateKey"] = templateKey
            extras["userId"] = userId
            extras["bizSubName"] = bizSubName
            extras["bizSubId"] = bizSubId
            extras["expertsServiceId"] = expertsServiceId
            response["extras"] = extras
            val mHandler = Handler(Looper.getMainLooper())
            val r = Runnable { //do something
//                channel?.invokeMethod("notificationClick", objectMapper.writeValueAsString(response))
            }
            //主线程中调用：
            mHandler.postDelayed(r, 100) //延时100毫秒
        } catch (e: Exception) {
            Log.w(TAG, "parse notification error")
        }
    }

    companion object {
        private const val TAG = "OpenClickActivity"
    }
}