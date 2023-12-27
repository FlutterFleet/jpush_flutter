package com.kjxbyz.plugins.jpush;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;

import com.kjxbyz.plugins.jpush.helper.JPushHelper;

import cn.jiguang.api.utils.JCollectionAuth;
import cn.jpush.android.api.JPushInterface;
import cn.jpush.android.data.JPushConfig;
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
        JPushHelper.getInstance().setContext(context).setChannel(channel);
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
    public void onAttachedToActivity(ActivityPluginBinding activityPluginBinding) {
        attachToActivity(activityPluginBinding);
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        disposeActivity();
    }

    @Override
    public void onReattachedToActivityForConfigChanges(ActivityPluginBinding activityPluginBinding) {
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
            case METHOD_INIT:
                String appKey = call.argument("appKey");
                String channel = call.argument("channel");
                delegate.init(appKey, channel, result);
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
        public void setDebugMode(boolean debugMode, MethodChannel.Result result);

        /**
         * 隐私确认接口
         * @param auth
         * @param result
         */
        public void setAuth(boolean auth, MethodChannel.Result result);

        /**
         * 调用了本 API 后，JPush 推送服务进行初始化.
         */
        public void init(String appKey, String channel, MethodChannel.Result result);

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
        public static final String SET_DEBUG_MODE_FAILED = "SET_DEBUG_MODE_FAILED";
        public static final String SET_AUTH_FAILED = "SET_AUTH_FAILED";
        public static final String INIT_FAILED = "INIT_FAILED";

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
                result.error(SET_DEBUG_MODE_FAILED, e.getMessage(), e.getStackTrace());
            }
        }

        @Override
        public void setAuth(boolean auth, MethodChannel.Result result) {
            if (this.context == null) return;
            try {
                JCollectionAuth.setAuth(this.context, auth);
                result.success(null);
            } catch (Exception e) {
                result.error(SET_AUTH_FAILED, e.getMessage(), e.getStackTrace());
            }
        }

        @Override
        public void init(String appKey, String channel, MethodChannel.Result result) {
            if (this.context == null) return;
            try {
                JPushConfig config = new JPushConfig();
                config.setjAppKey(appKey);
                JPushInterface.init(this.context);
//                JPushInterface.setChannel(this.context, channel);
                result.success(null);
            } catch (Exception e) {
                result.error(INIT_FAILED, e.getMessage(), e.getStackTrace());
            }
        }

        @Override
        public void setAlias(int sequence, String alias, MethodChannel.Result result) {
            if (this.context == null) return;
            try {
                JPushInterface.setAlias(this.context, sequence, alias);
                result.success(null);
            } catch (Exception e) {
                result.error(INIT_FAILED, e.getMessage(), e.getStackTrace());
            }
        }

        @Override
        public void deleteAlias(int sequence, MethodChannel.Result result) {
            if (this.context == null) return;
            try {
                JPushInterface.deleteAlias(this.context, sequence);
                result.success(null);
            } catch (Exception e) {
                result.error(INIT_FAILED, e.getMessage(), e.getStackTrace());
            }
        }
    }
}
