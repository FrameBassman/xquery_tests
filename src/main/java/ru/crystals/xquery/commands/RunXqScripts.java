package ru.crystals.xquery.commands;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.stream.Collectors;

public class RunXqScripts extends ResourcesRelatedCommand {
    private String directoryPath;

    public RunXqScripts() {
        directoryPath = "xq";
    }

    @Override
    public void update() throws Exception {
        List<Path> paths = Files.walk(Paths.get(classLoader.getResource(directoryPath).getPath()))
            .filter(file -> Files.isRegularFile(file)).collect(Collectors.toList());
        for (Path path : paths) {
            RunXqScript run = new RunXqScript(toRelatedPath(path));
            run.update();
        }
    }

    @Override
    public void restore() {

    }

    protected String toRelatedPath(Path absolute) {
        return absolute.toString().replace(classLoader.getResource(directoryPath).getPath(), directoryPath);
    }
}
