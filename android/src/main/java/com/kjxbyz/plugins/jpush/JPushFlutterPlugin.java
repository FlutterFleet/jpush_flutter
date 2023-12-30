package com.kjxbyz.plugins.jpush;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;

import com.kjxbyz.plugins.jpush.helper.JPushHelper;

import org.apache.commons.lang3.StringUtils;

import cn.jiguang.api.utils.JCollectionAuth;
import cn.jpush.android.api.JPushInterface;
import cn.jpush.android.data.JPushConfig;
import cn.jpush.android.ups.JPushUPSManager;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.PluginRegistry;

public class JPushFlutterPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
    private static final String CHANNEL_NAME = "plugins.kjxbyz.com/jpush_flutter_plugin";
    private static final String METHOD_SET_DEBUG_MODE = "setDebugMode";
    private static final String METHOD_SET_AUTH = "setAuth";
    private static final String METHOD_INIT = "init";
    private static final String METHOD_REGISTER_TOKEN = "registerToken";
    private static final String METHOD_UNREGISTER_TOKEN = "unRegisterToken";
    private static final String METHOD_TURN_OFF_PUSH = "turnOffPush";
    private static final String METHOD_TURN_ON_PUSH = "turnOnPush";
    private static final String METHOD_STOP_PUSH = "stopPush";
    private static final String METHOD_RESUME_PUSH = "resumePush";
    private static final String METHOD_IS_PUSH_STOPPED = "isPushStopped";
    private static final String METHOD_SET_ALIAS = "setAlias";
    private static final String METHOD_DELETE_ALIAS = "deleteAlias";


    private MethodChannel channel;
    private Context context = null;
    private Delegate delegate;
    private ActivityPluginBinding activityPluginBinding;

    @SuppressWarnings("deprecation")
    public static void registerWith(PluginRegistry.Registrar registrar) {
        JPushFlutterPlugin instance = new JPushFlutterPlugin();
        instance.initInstance(registrar.messenger(), registrar.context());
        JPushHelper.getInstance().setRegistrar(registrar);
        instance.setUpRegistrar(registrar);
    }

    @VisibleForTesting
    public void initInstance(BinaryMessenger messenger, Context context) {
        channel = new MethodChannel(messenger, CHANNEL_NAME);
        JPushHelper.getInstance().setContext(context);
        JPushHelper.getInstance().setChannel(channel);
        this.context = context;
        delegate = new Delegate(context);
        channel.setMethodCallHandler(this);
    }

    @VisibleForTesting
    @SuppressWarnings("deprecation")
    public void setUpRegistrar(PluginRegistry.Registrar registrar) {
        JPushHelper.getInstance().setRegistrar(registrar);
        delegate.setUpRegistrar(registrar);
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        initInstance(binding.getBinaryMessenger(), binding.getApplicationContext());
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        dispose();
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding activityPluginBinding) {
        attachToActivity(activityPluginBinding);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        disposeActivity();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding activityPluginBinding) {
        attachToActivity(activityPluginBinding);
    }

    @Override
    public void onDetachedFromActivity() {
        disposeActivity();
    }

    private void attachToActivity(ActivityPluginBinding activityPluginBinding) {
        this.activityPluginBinding = activityPluginBinding;
        activityPluginBinding.addActivityResultListener(delegate);
        Activity activity = activityPluginBinding.getActivity();
        JPushHelper.getInstance().setActivity(activity);
        delegate.setActivity(activity);
    }

    private void disposeActivity() {
        activityPluginBinding.removeActivityResultListener(delegate);
        JPushHelper.getInstance().setActivity(null);
        delegate.setActivity(null);
        activityPluginBinding = null;
    }

    private void dispose() {
        context = null;
        delegate = null;
        channel.setMethodCallHandler(null);
        channel = null;
        JPushHelper.getInstance().setContext(null);
        JPushHelper.getInstance().setRegistrar(null);
        JPushHelper.getInstance().setChannel(null);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case METHOD_SET_DEBUG_MODE:
                boolean debugMode = call.argument("debugMode");
                delegate.setDebugMode(debugMode, result);
                break;
            case METHOD_SET_AUTH:
                boolean auth = call.argument("auth");
                delegate.setAuth(auth, result);
                break;
            case METHOD_REGISTER_TOKEN:
                String appId = call.argument("appId");
                String channelVal = call.argument("channel");
                delegate.registerToken(appId, channelVal, result);
                break;
            case METHOD_UNREGISTER_TOKEN:
                delegate.unRegisterToken(result);
                break;
            case METHOD_TURN_OFF_PUSH:
                delegate.turnOffPush(result);
                break;
            case METHOD_TURN_ON_PUSH:
                delegate.turnOnPush(result);
                break;
            case METHOD_INIT:
                String appKey = call.argument("appKey");
                String channel = call.argument("channel");
                delegate.init(appKey, channel, result);
                break;
            case METHOD_STOP_PUSH:
                delegate.stopPush(result);
                break;
            case METHOD_RESUME_PUSH:
                delegate.resumePush(result);
                break;
            case METHOD_IS_PUSH_STOPPED:
                delegate.isPushStopped(result);
                break;
            case METHOD_SET_ALIAS:
                int sequence = call.argument("sequence");
                String alias = call.argument("alias");
                delegate.setAlias(sequence, alias, result);
                break;
            case METHOD_DELETE_ALIAS:
                int deleteSequence = call.argument("sequence");
                delegate.deleteAlias(deleteSequence, result);
                break;
            default:
                result.notImplemented();
        }
    }

    public interface IDelegate {

        /**
         * 该接口需在 init 接口之前调用，避免出现部分日志没打印的情况.
         */
        void setDebugMode(boolean debugMode, MethodChannel.Result result);

        /**
         * 隐私确认接口
         */
        public void setAuth(boolean auth, MethodChannel.Result result);

        /**
         * 注册接口.
         */
        public void registerToken(String appId, String channel, MethodChannel.Result result);

        /**
         * 调用此接口后，会停用所有 Push SDK 提供的功能。需通过 registerToken 接口或者重新安装应用才可恢复.
         */
        public void unRegisterToken(MethodChannel.Result result);

        /**
         * 调用了本 API 后，JPush 推送服务完全被停止。具体表现为：
         * 收不到推送消息
         * 极光推送所有的其他 API 调用都无效，需要调用 cn.jpush.android.ups.JPushUPSManager.turnOnPush 恢复.
         */
        public void turnOffPush(MethodChannel.Result result);

        /**
         * 调用了此 API 后，极光推送完全恢复正常工作.
         */
        public void turnOnPush(MethodChannel.Result result);

        /**
         * 初始化极光推送服务，调用了本 API 后，开启JPush 推送服务，将会开始收集上报SDK业务功能所必要的用户个人信息。
         * 建议在自定义的 Application 中的 onCreate 中调用。 该 API 支持动态设置极光 AppKey 与各厂商 AppId。
         * 注：如使用该接口配置 AppKey 进行初始化，则 build.gradle 文件中 JPUSH_APPKEY 则不需再配置，即 JPUSH_APPKEY : ""。.
         */
        public void init(String appKey, String channel, MethodChannel.Result result);

        /**
         * 调用了本 API 后，JPush 推送服务完全被停止.
         * 1. 收不到推送消息
         * 2. 极光推送所有的其他 API 调用都无效，不能通过 JPushInterface.init 恢复，需要调用 resumePush 恢复
         */
        public void stopPush(MethodChannel.Result result);

        /**
         * 调用了此 API 后，极光推送完全恢复正常工作.
         */
        public void resumePush(MethodChannel.Result result);

        /**
         * 检查推送是否被停止.
         */
        public void isPushStopped(MethodChannel.Result result);

        /**
         * 调用此 API 来设置别名。
         * 需要理解的是，这个接口是覆盖逻辑，而不是增量逻辑。即新的调用会覆盖之前的设置。
         */
        public void setAlias(int sequence, String alias, MethodChannel.Result result);

        /**
         * 调用此 API 来删除别名。
         */
        public void deleteAlias(int sequence, MethodChannel.Result result);

    }

    public static class Delegate implements IDelegate, PluginRegistry.ActivityResultListener {
        private static final String TAG = "Delegate";

        private final Context context;

        @SuppressWarnings("deprecation")
        private PluginRegistry.Registrar registrar;

        private Activity activity;

        public Delegate(Context context) {
            this.context = context;
        }

        @SuppressWarnings("deprecation")
        public void setUpRegistrar(PluginRegistry.Registrar registrar) {
            this.registrar = registrar;
            registrar.addActivityResultListener(this);
        }

        public void setActivity(Activity activity) {
            this.activity = activity;
        }

        // Only access activity with this method.
        public Activity getActivity() {
            return registrar != null ? registrar.activity() : activity;
        }

        @Override
        public boolean onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
            return false;
        }

        @Override
        public void setDebugMode(boolean debugMode, MethodChannel.Result result) {
            try {
                JPushInterface.setDebugMode(debugMode);
                result.success(null);
            } catch (Exception e) {
                result.error(METHOD_SET_DEBUG_MODE, e.getMessage(), e.getStackTrace());
            }
        }

        @Override
        public void setAuth(boolean auth, MethodChannel.Result result) {
            if (this.context == null) {
                Log.e(TAG, "[setAuth]: context is null");
                result.error(METHOD_SET_AUTH, "[setAuth]: context is null", null);
                return;
            }
            try {
                JCollectionAuth.setAuth(this.context, auth);
                result.success(null);
            } catch (Exception e) {
                result.error(METHOD_SET_AUTH, e.getMessage(), e.getStackTrace());
            }
        }

        @Override
        public void registerToken(String appId, String channel, MethodChannel.Result result) {
            if (this.context == null) {
                Log.e(TAG, "[registerToken]: context is null");
                result.error(METHOD_REGISTER_TOKEN, "[registerToken]: context is null", null);
                return;
            }
            try {
                JPushUPSManager.registerToken(this.context, appId, null, "", tokenResult -> {
                    Log.i(TAG, "[registerToken]: token is " + tokenResult.getToken() + ", code is " + tokenResult.getReturnCode() + ", type is " + tokenResult.getActionType());
                    if (tokenResult.getReturnCode() == 0 && !StringUtils.isEmpty(channel)) {
                        JPushInterface.setChannel(this.context, channel);
                    }
                    result.success(tokenResult.getReturnCode());
                });
            } catch (Exception e) {
                result.error(METHOD_REGISTER_TOKEN, e.getMessage(), e.getStackTrace());
            }
        }

        @Override
        public void unRegisterToken(MethodChannel.Result result) {
            if (this.context == null) {
                Log.e(TAG, "[unRegisterToken]: context is null");
                result.error(METHOD_UNREGISTER_TOKEN, "[unRegisterToken]: context is null", null);
                return;
            }
            try {
                JPushUPSManager.unRegisterToken(this.context, tokenResult -> {
                    Log.i(TAG, "[unRegisterToken]: token is " + tokenResult.getToken() + ", code is " + tokenResult.getReturnCode() + ", type is " + tokenResult.getActionType());
                    result.success(tokenResult.getReturnCode());
                });
            } catch (Exception e) {
                result.error(METHOD_UNREGISTER_TOKEN, e.getMessage(), e.getStackTrace());
            }
        }

        @Override
        public void turnOffPush(MethodChannel.Result result) {
            if (this.context == null) {
                Log.e(TAG, "[turnOffPush]: context is null");
                result.error(METHOD_TURN_OFF_PUSH, "[turnOffPush]: context is null", null);
                return;
            }
            try {
                JPushUPSManager.turnOffPush(this.context, tokenResult -> {
                    Log.i(TAG, "[turnOffPush]: token is " + tokenResult.getToken() + ", code is " + tokenResult.getReturnCode() + ", type is " + tokenResult.getActionType());
                    result.success(tokenResult.getReturnCode());
                });
            } catch (Exception e) {
                result.error(METHOD_TURN_OFF_PUSH, e.getMessage(), e.getStackTrace());
            }
        }

        @Override
        public void turnOnPush(MethodChannel.Result result) {
            if (this.context == null) {
                Log.e(TAG, "[turnOnPush]: context is null");
                result.error(METHOD_TURN_ON_PUSH, "[turnOnPush]: context is null", null);
                return;
            }
            try {
                JPushUPSManager.turnOnPush(this.context, tokenResult -> {
                    Log.i(TAG, "[turnOnPush]: token is " + tokenResult.getToken() + ", code is " + tokenResult.getReturnCode() + ", type is " + tokenResult.getActionType());
                    result.success(tokenResult.getReturnCode());
                });
            } catch (Exception e) {
                result.error(METHOD_TURN_ON_PUSH, e.getMessage(), e.getStackTrace());
            }
        }

        @Override
        public void init(String appKey, String channel, MethodChannel.Result result) {
            if (this.context == null) {
                Log.e(TAG, "[init]: context is null");
                result.error(METHOD_INIT, "[init]: context is null", null);
                return;
            }
            try {
                if (!StringUtils.isEmpty(appKey)) {
                    JPushConfig config = new JPushConfig();
                    config.setjAppKey(appKey);
                    JPushInterface.init(this.context, config);
                } else {
                    JPushInterface.init(this.context);
                }
                if (!StringUtils.isEmpty(channel)) {
                    JPushInterface.setChannel(this.context, channel);
                }
                result.success(null);
            } catch (Exception e) {
                result.error(METHOD_INIT, e.getMessage(), e.getStackTrace());
            }
        }

        @Override
        public void stopPush(MethodChannel.Result result) {
            if (this.context == null) {
                Log.e(TAG, "[stopPush]: context is null");
                result.error(METHOD_STOP_PUSH, "[stopPush]: context is null", null);
                return;
            }
            try {
                JPushInterface.stopPush(this.context);
                result.success(null);
            } catch (Exception e) {
                result.error(METHOD_STOP_PUSH, e.getMessage(), e.getStackTrace());
            }
        }

        @Override
        public void resumePush(MethodChannel.Result result) {
            if (this.context == null) {
                Log.e(TAG, "[resumePush]: context is null");
                result.error(METHOD_RESUME_PUSH, "[resumePush]: context is null", null);
                return;
            }
            try {
                JPushInterface.resumePush(this.context);
                result.success(null);
            } catch (Exception e) {
                result.error(METHOD_RESUME_PUSH, e.getMessage(), e.getStackTrace());
            }
        }

        @Override
        public void isPushStopped(MethodChannel.Result result) {
            if (this.context == null) {
                Log.e(TAG, "[isPushStopped]: context is null");
                result.error(METHOD_IS_PUSH_STOPPED, "[isPushStopped]: context is null", null);
                return;
            }
            try {
                boolean isPushStopped = JPushInterface.isPushStopped(this.context);
                result.success(isPushStopped);
            } catch (Exception e) {
                result.error(METHOD_IS_PUSH_STOPPED, e.getMessage(), e.getStackTrace());
            }
        }

        @Override
        public void setAlias(int sequence, String alias, MethodChannel.Result result) {
            if (this.context == null) {
                Log.e(TAG, "[setAlias]: context is null");
                result.error(METHOD_SET_ALIAS, "[setAlias]: context is null", null);
                return;
            }
            try {
                JPushInterface.setAlias(this.context, sequence, alias);
                result.success(0);
            } catch (Exception e) {
                result.error(METHOD_SET_ALIAS, e.getMessage(), e.getStackTrace());
            }
        }

        @Override
        public void deleteAlias(int sequence, MethodChannel.Result result) {
            if (this.context == null) {
                Log.e(TAG, "[deleteAlias]: context is null");
                result.error(METHOD_DELETE_ALIAS, "[deleteAlias]: context is null", null);
                return;
            }
            try {
                JPushInterface.deleteAlias(this.context, sequence);
                result.success(0);
            } catch (Exception e) {
                result.error(METHOD_DELETE_ALIAS, e.getMessage(), e.getStackTrace());
            }
        }
    }
}
