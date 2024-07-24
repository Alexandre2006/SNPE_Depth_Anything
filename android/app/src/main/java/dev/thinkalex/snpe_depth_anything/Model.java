package dev.thinkalex.snpe_depth_anything;

import static java.lang.Integer.parseInt;

import android.app.Application;
import android.net.Uri;
import android.os.SystemClock;
import android.util.Log;

import com.qualcomm.qti.snpe.NeuralNetwork;
import com.qualcomm.qti.snpe.SNPE;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
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
    public Model(Application application, String path, NeuralNetwork.Runtime runtime, NeuralNetwork.PerformanceProfile performanceProfile) throws IOException {
        MODEL_PATH = path;
        MODEL_NAME = getModelName(path);
        MODEL_INPUT_SIZE = getModelInputSize(path);
        MODEL_ENCODER = getModelEncoder(path);

        MODEL_RUNTIME = runtime;
        MODEL_PERFORMANCE_PROFILE = performanceProfile;

        // Load the model
        network = loadModel(application);
    }

    // Model Loader
    private NeuralNetwork loadModel(Application application) throws IOException, IllegalArgumentException {
        // Verify model path validity
        if (!isValidModelName(MODEL_PATH)) {
            throw new IllegalArgumentException("Invalid model name: " + MODEL_PATH);
        }

        // Load the model
        try {
            // Load file from assets
            final InputStream modelStream = application.getResources().getAssets().open("flutter_assets/models/" + MODEL_PATH);

            // Create temp file
            File modelFile = File.createTempFile("model", ".dlc", application.getCacheDir());
            modelFile.deleteOnExit();

            // Copy model into temp file
            try (OutputStream out = new FileOutputStream(modelFile)) {
                byte[] buffer = new byte[1024];
                int read;
                while ((read = modelStream.read(buffer)) != -1) {
                    out.write(buffer, 0, read);
                }
            }

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

    // Utilities - Model Info
    public static List<String> getAvailableModels(Application application) throws IOException {
        // Get files in models folder
        String[] resources = application.getResources().getAssets().list("flutter_assets/models");

        // Remove non-model files
        resources = Arrays.stream(resources).filter(file -> file.endsWith(".dlc")).toArray(String[]::new);

        // Remove invalid model names
        resources = Arrays.stream(resources).filter(Model::isValidModelName).toArray(String[]::new);

        // Return files
        return Arrays.asList(resources);
    }

    public static boolean isValidModelName(String modelName) {
        // Check if file format is valid
        if (!modelName.endsWith(".dlc")) {
            return false;
        }

        // Verify if size, encoder, and version are valid
        String noExt = modelName.substring(0, modelName.length() - 4);
        String[] parts = noExt.split("_");

        // Check if size (last part) is valid
        try {
            int size = parseInt(parts[parts.length - 1]);
            if (size % 14 != 0) {
                return false;
            }
        } catch (NumberFormatException e) {
            return false;
        }

        // Check if encoder is valid
        List<String> encoders = Arrays.asList("vits", "vitb", "vitl", "vitg");
        if (!encoders.contains(parts[parts.length - 2])) {
            return false;
        }

        // Verify model name
        return modelName.contains("depth_anything_v2") || modelName.contains("depth_anything_v1");
    }

    public static String getModelName(String modelName) {
        if (modelName.contains("depth_anything_v1")) {
            return "Depth Anything v1";
        } else if (modelName.contains("depth_anything_v2")) {
            return "Depth Anything v2";
        } else {
            return "Unknown";
        }
    }

    public static int getModelInputSize(String modelName) {
        String noExt = modelName.substring(0, modelName.length() - 4);
        String[] parts = noExt.split("_");
        return parseInt(parts[parts.length - 1]);
    }

    public static String getModelEncoder(String modelName) {
        String noExt = modelName.substring(0, modelName.length() - 4);
        String[] parts = noExt.split("_");
        return parts[parts.length - 2];
    }
}
