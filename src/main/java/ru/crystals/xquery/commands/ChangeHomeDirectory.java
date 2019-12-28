package ru.crystals.xquery.commands;

public class ChangeHomeDirectory extends ResourcesRelatedCommand {
    private String backed;
    private String currentResourcesPath;

    public ChangeHomeDirectory(String configsPath) {
        backed = System.getProperty("user.dir");
        currentResourcesPath = configsPath;
    }

    @Override
    public void update() {
        System.setProperty("user.dir", classLoader.getResource(currentResourcesPath).getPath());
    }

    @Override
    public void restore() {
        System.setProperty("user.dir", backed);
    }
}
