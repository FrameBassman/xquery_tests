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
            log.info("");
        } else {
            System.setProperty("user.dir", classLoader.getResource(currentResourcesPath).getPath());
        }
    }

    @Override
    public void restore() {
        System.setProperty("user.dir", backed);
    }
}
