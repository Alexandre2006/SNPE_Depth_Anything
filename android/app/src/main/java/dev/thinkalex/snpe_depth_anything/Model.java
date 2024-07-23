package dev.thinkalex.snpe_depth_anything;

import android.app.Application;
import android.net.Uri;
import android.os.SystemClock;
import android.util.Log;

import com.qualcomm.qti.snpe.NeuralNetwork;
import com.qualcomm.qti.snpe.SNPE;

import java.io.File;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;

public class Model {
    // LOG TAG
    private static final String LOG_TAG = Model.class.getSimpleName();

    // Model Info
    public static String MODEL_PATH;
    public static String MODEL_NAME;
    public static int MODEL_INPUT_SIZE;
    public static String MODEL_ENCODER;

    // Model Preferences
    public static NeuralNetwork.Runtime MODEL_RUNTIME;
    public static NeuralNetwork.PerformanceProfile MODEL_PERFORMANCE_PROFILE;

    // Private
    private static NeuralNetwork network;

    // Constructor
    public Model(Application application, String path, String encoder, NeuralNetwork.Runtime runtime, NeuralNetwork.PerformanceProfile performanceProfile) throws IOException {
        MODEL_PATH = path;
        MODEL_NAME = name;
        MODEL_INPUT_SIZE = inputSize;
        MODEL_ENCODER = encoder;

        MODEL_RUNTIME = runtime;
        MODEL_PERFORMANCE_PROFILE = performanceProfile;

        // Load the model
        network = loadModel(application);
    }

    // Model Loader
    private NeuralNetwork loadModel(Application application) throws IOException {
        // Load the model
        try {
            // Load file
            final Uri modelUri = Uri.parse(MODEL_PATH);
            final File modelFile = new File(modelUri.getPath());

            // Create the model builder (holds model info, used to load model)
            final SNPE.NeuralNetworkBuilder builder = new SNPE.NeuralNetworkBuilder(application)
                    .setDebugEnabled(false)
                    .setRuntimeOrder(MODEL_RUNTIME)
                    .setModel(modelFile)
                    .setCpuFallbackEnabled(true)
                    .setUnsignedPD(true)
                    .setPerformanceProfile(MODEL_PERFORMANCE_PROFILE);

            // Add unsignedPD check
            builder.setRuntimeCheckOption(NeuralNetwork.RuntimeCheckOption.UNSIGNEDPD_CHECK);

            // Load the model
            final long start = SystemClock.elapsedRealtime();
            network = builder.build();
            final long end = SystemClock.elapsedRealtime();

            // Log time to load model
            Log.d(LOG_TAG, "Model Load Time: " + (end - start) + "ms");

            // Return the loaded model
            return network;
        } catch (IllegalStateException | IOException e) {
            // Log Error
            Log.e(LOG_TAG, e.getMessage(), e);

            // Rethrow error
            throw e;
        }
    }

    // Inference

    // Utilities
    public static List<String> getAvailableModels(Application application) throws IOException {
        // Get files in models folder
        String[] resources = application.getResources().getAssets().list("flutter_assets/models");

        // Remove non-model files
        resources = Arrays.stream(resources).filter(file -> file.endsWith(".dlc")).toArray(String[]::new);

        // Return files
        return Arrays.asList(resources);
    }
}
