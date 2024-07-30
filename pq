package com.example.demo.service;

import org.springframework.stereotype.Service;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.LinkedBlockingQueue;

@Service
public class DataProcessingService {

    @PersistenceContext
    private EntityManager entityManager;

    private static final int BATCH_SIZE = 1000;
    private static final String OUTPUT_DIR = "src/main/resources/output";

    private final BlockingQueue<Object[]> queue = new LinkedBlockingQueue<>(BATCH_SIZE * 2);
    private final ExecutorService executorService = Executors.newFixedThreadPool(3);

    public void processLargeData() {
        CompletableFuture<Void> producerFuture = CompletableFuture.runAsync(this::readDataFromDatabase, executorService);

        CompletableFuture<Void> parquetConsumerFuture = CompletableFuture.runAsync(() -> processBatch("parquet"), executorService);
        CompletableFuture<Void> excelConsumerFuture = CompletableFuture.runAsync(() -> processBatch("excel"), executorService);

        producerFuture.join();  // Ensure producer finishes first
        CompletableFuture.allOf(parquetConsumerFuture, excelConsumerFuture)
                .thenRunAsync(this::uploadFilesAndSendEmail, executorService)
                .exceptionally(ex -> {
                    ex.printStackTrace();
                    return null;
                }).join();  // Wait for all to complete
    }

    private void readDataFromDatabase() {
        try {
            Query query = entityManager.createQuery("SELECT e.field1, e.field2, e.field3 FROM Entity e");
            query.setHint("org.hibernate.fetchSize", BATCH_SIZE);
            query.unwrap(org.hibernate.query.Query.class)
                    .scroll(org.hibernate.ScrollMode.FORWARD_ONLY)
                    .forEachRemaining(record -> {
                        try {
                            queue.put((Object[]) record);
                        } catch (InterruptedException e) {
                            Thread.currentThread().interrupt();
                        }
                    });
        } finally {
            // Signal end of data
            try {
                queue.put(new Object[0]);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        }
    }

    private void processBatch(String fileType) {
        List<Object[]> buffer = new ArrayList<>();
        try {
            while (true) {
                Object[] record = queue.take();
                if (record.length == 0) {  // End of data signal
                    if (!buffer.isEmpty()) {
                        writeBatchToFile(buffer, fileType);
                    }
                    break;
                }
                buffer.add(record);
                if (buffer.size() >= BATCH_SIZE) {
                    writeBatchToFile(buffer, fileType);
                    buffer.clear();
                }
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }

    private void writeBatchToFile(List<Object[]> batch, String fileType) {
        String outputFilePath = OUTPUT_DIR + "/output-" + System.nanoTime() + "." + fileType;
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(outputFilePath))) {
            writer.write("[");
            for (int i = 0; i < batch.size(); i++) {
                Object[] line = batch.get(i);
                writer.write("[");
                for (int j = 0; j < line.length; j++) {
                    writer.write(line[j].toString());
                    if (j < line.length - 1) {
                        writer.write(",");
                    }
                }
                writer.write("]");
                if (i < batch.size() - 1) {
                    writer.write(",");
                }
            }
            writer.write("]");
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private void uploadFilesAndSendEmail() {
        // Implement your upload and email logic here
        System.out.println("Uploading files and sending email.");
    }
}