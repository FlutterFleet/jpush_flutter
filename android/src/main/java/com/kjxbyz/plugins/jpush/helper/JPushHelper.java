package com.kjxbyz.plugins.jpush.helper;

import android.app.Activity;
import android.content.Context;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;

public class JPushHelper {
    private Context context;

    private MethodChannel channel;

    @SuppressWarnings("deprecation")
    private PluginRegistry.Registrar registrar;

    private Activity activity;

    private JPushHelper() {}

    public static JPushHelper getInstance() {
        return JPushHelperBuilder.instance;
    }

    private static class JPushHelperBuilder {
        private static final JPushHelper instance = new JPushHelper();
    }

    public void setContext(Context context) {
        this.context = context;
    }

    public void setChannel(MethodChannel channel) {
        this.channel = channel;
    }

    @SuppressWarnings("deprecation")
    public void setRegistrar(PluginRegistry.Registrar registrar) {
        this.registrar = registrar;
    }

    public void setActivity(Activity activity) {
        this.activity = activity;
    }

    public Context getContext() {
        return this.context;
    }

    public MethodChannel getChannel() {
        return this.channel;
    }

    @SuppressWarnings("deprecation")
    public PluginRegistry.Registrar getRegistrar() {
        return this.registrar;
    }

    public Activity getActivity() {
        if (this.registrar != null) return this.registrar.activity();
        return this.activity;
    }
}
