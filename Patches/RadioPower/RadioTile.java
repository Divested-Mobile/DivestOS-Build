package com.android.systemui.qs.tiles;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;

import android.util.Log;
import com.android.systemui.R;
import com.android.systemui.qs.QSTile;
import org.cyanogenmod.internal.util.QSUtils;

import com.android.internal.telephony.Phone;
import com.android.internal.telephony.PhoneFactory;

import com.android.internal.logging.MetricsLogger;

public class RadioTile extends QSTile<QSTile.BooleanState> {

    private boolean mListening;
    private Phone phone = null;

    public RadioTile(Host host) {
        super(host);
	phone = PhoneFactory.getDefaultPhone();
    }

    @Override
    protected BooleanState newTileState() {
        return new BooleanState();
    }

    @Override
    protected void handleClick() {
        boolean newState = !getState().value;
        setState(newState);
        refreshState();
    }

    @Override
    protected void handleLongClick() {
	Intent launchRadioInfo = new Intent();
	launchRadioInfo.setClassName("com.android.settings", "com.android.settings.RadioInfo");
        mHost.startActivityDismissingKeyguard(launchRadioInfo);
    }

    private void setState(boolean state) {
        phone.setRadioPower(state);
    }

    @Override
    public int getMetricsCategory() {
        return MetricsLogger.QS_AIRPLANEMODE;
    }

    @Override
    protected void handleUpdateState(BooleanState state, Object arg) {
	state.visible = true;
	final boolean radioPower = arg instanceof Boolean ? (boolean) arg : phone.isRadioOn();
	state.value = radioPower;
	state.label = mContext.getString(R.string.quick_settings_radio_power_label);
	if(state.value) {
		state.icon = ResourceIcon.get(R.drawable.ic_qs_radio_on);
	} else {
		state.icon = ResourceIcon.get(R.drawable.ic_qs_radio_off);
	}
    }

    @Override
    public void setListening(boolean listening) {
        if (mListening == listening) return;
        mListening = listening;
        if (listening) {
            final IntentFilter filter = new IntentFilter();
            filter.addAction(Intent.ACTION_AIRPLANE_MODE_CHANGED);
            mContext.registerReceiver(mReceiver, filter);
        } else {
            mContext.unregisterReceiver(mReceiver);
        }
    }

    private final BroadcastReceiver mReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (Intent.ACTION_AIRPLANE_MODE_CHANGED.equals(intent.getAction())) {
                refreshState();
            }
        }
    };
}
