package ru.crystals.xquery.commands;

import ru.crystals.xquery.ConsoleLogger;

public class ChangeHomeDirectory extends ResourcesRelatedCommand {
    private ConsoleLogger log;
    private String backed;
    private String currentResourcesPath;

    public ChangeHomeDirectory(ConsoleLogger logger, String configsPath) {
        log = logger;
        backed = System.getProperty("user.dir");
        currentResourcesPath = configsPath;
    }

    @Override
    public void update() {
        if (classLoader.getResource(currentResourcesPath) == null) {
            String crystalCashPath = "src/main/resources/crystal-cash";
            String xqPath = "src/main/resources/xq";
            log.info(String.format("You should place cash configs in '%s' folder and your XQ files in '%s' directory.", crystalCashPath, xqPath));
        } else {
            System.setProperty("user.dir", classLoader.getResource(currentResourcesPath).getPath());
        }
    }

    @Override
    public void restore() {
        System.setProperty("user.dir", backed);
    }
}
