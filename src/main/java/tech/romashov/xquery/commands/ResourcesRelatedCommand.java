package tech.romashov.xquery.commands;

public abstract class ResourcesRelatedCommand extends Command {
    protected ClassLoader classLoader;

    public ResourcesRelatedCommand() {
        classLoader = getClass().getClassLoader();
    }
}
