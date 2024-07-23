package dev.thinkalex.snpe_depth_anything;

import android.app.Application;
import android.net.Uri;
import android.os.SystemClock;
import android.util.Log;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.util.ViewUtils;

import com.qualcomm.qti.snpe.NeuralNetwork;
import com.qualcomm.qti.snpe.SNPE;
import com.qualcomm.qti.snpe.Tensor;

import java.io.File;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;

public class MainActivity extends FlutterActivity {
    // Currently loaded model
    Model currentModel;

    // Channel
    private static String CHANNEL = "dev.thinkalex.snpe_depth_anything/model";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("getAvailableModels")) {
                        try {
                            result.success(Model.getAvailableModels(this.getApplication()));
                        } catch (IOException e) {
                            result.error("IOException", e.getMessage(), e.getStackTrace());
                        }
                    }
                }
        );
    }
}

//enum Runtime {
//    CPU,
//    GPU,
//    GPU_FLOAT16,
//    DSP,
//}

//enum PerformanceProfile {
//    // High Performance
//    BURST, // Fastest (not intended for continuous use)
//    HIGH_PERFORMANCE,
//    SUSTAINED_HIGH_PERFORMANCE, // Fastest (intended for continuous use)
//
//    // Balanced
//    BALANCED,
//    LOW_BALANCED,
//
//    // Power Saving
//    LOW_POWER_SAVER,
//    POWER_SAVER,
//    HIGH_POWER_SAVER,
//    EXTREME_POWER_SAVER, // Most Efficient
//
//    // Defaults
//    DEFAULT, // Default (from SNPE library)
//    SYSTSEM_SETTINGS, // Default (based on system settings)
//}


