import ceylon.collection {
    LinkedList
}
import ceylon.file {
    File
}
import ceylon.json {
    parse,
    Value
}


shared abstract class Files() of files {
    shared String readString(File file) {
        try (reader = file.Reader()) {
            value content = LinkedList<String>();
            while (exists line = reader.readLine()) {
                content.add(line);
            }
            return "\n".join(content);
        }
    }

    shared Value readJson(File file) {
        return parse(readString(file));
    }
}
shared object files extends Files() {}
