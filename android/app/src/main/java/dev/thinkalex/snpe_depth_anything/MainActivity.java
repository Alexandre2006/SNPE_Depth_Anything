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
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class MainActivity extends FlutterActivity {
    // String -> Enums
    private static final Map<String, NeuralNetwork.Runtime> RUNTIME_MAP = new HashMap<String, NeuralNetwork.Runtime>() {{
        put("cpu", NeuralNetwork.Runtime.CPU);
        put("gpu", NeuralNetwork.Runtime.GPU);
        put("gpuFloat16", NeuralNetwork.Runtime.GPU_FLOAT16);
        put("dsp", NeuralNetwork.Runtime.DSP);
    }};

    private static final Map<String, NeuralNetwork.PerformanceProfile> PERFORMANCE_PROFILE_MAP = new HashMap<String, NeuralNetwork.PerformanceProfile>() {{
        put("burst", NeuralNetwork.PerformanceProfile.BURST);
        put("highPerformance", NeuralNetwork.PerformanceProfile.HIGH_PERFORMANCE);
        put("sustainedHighPerformance", NeuralNetwork.PerformanceProfile.SUSTAINED_HIGH_PERFORMANCE);
        put("balanced", NeuralNetwork.PerformanceProfile.BALANCED);
        put("lowBalanced", NeuralNetwork.PerformanceProfile.LOW_BALANCED);
        put("lowPowerSaver", NeuralNetwork.PerformanceProfile.LOW_POWER_SAVER);
        put("powerSaver", NeuralNetwork.PerformanceProfile.POWER_SAVER);
        put("highPowerSaver", NeuralNetwork.PerformanceProfile.HIGH_POWER_SAVER);
        put("extremePowerSaver", NeuralNetwork.PerformanceProfile.EXTREME_POWER_SAVER);
        put("snpeDefault", NeuralNetwork.PerformanceProfile.DEFAULT);
        put("systemDefault", NeuralNetwork.PerformanceProfile.SYSTEM_SETTINGS);
    }};

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
                    } else if (call.method.equals("loadModel")) {
                        // Get Arguments
                        String modelPath = call.argument("modelPath");
                        String runtime = call.argument("runtime");
                        String performanceProfile = call.argument("performanceProfile");

                        // Convert Arguments to Enums
                        NeuralNetwork.Runtime runtimeEnum = RUNTIME_MAP.get(runtime);
                        NeuralNetwork.PerformanceProfile performanceProfileEnum = PERFORMANCE_PROFILE_MAP.get(performanceProfile);

                        // Load Model
                        try {
                            currentModel = new Model(this.getApplication(), modelPath, runtimeEnum, performanceProfileEnum);
                            result.success("Model Loaded");
                        } catch (IOException e) {
                            result.error("IOException", e.getMessage(), e.getStackTrace());
                        }
                    }
                }
        );
    }
}

