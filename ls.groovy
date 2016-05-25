ls = { -> 
    "docker-machine ls".execute()
        .text
        .split(/\n/)
        .tail()
        .toList()
        .collect { line ->
            final matcher = line =~/^\w+/
            final name = matcher[0]

            final isRunning = line.contains "Running"

            [name: name, isRunning: isRunning]
        }
        .grep { it.isRunning } 
        .collect { it.name }
}

getEnvironmentForDockerMachine = { dockerMachine -> 
    "docker-machine env ${dockerMachine}".execute()
        .text
        .readLines()
        .grep { ! it.startsWith("#") }
        .collect { it.replaceFirst("export ", "")}
        .collect { it.split "=" }
        .collectEntries { it -> 
            def (key, value) = it;
            [key, value[1..-2] ]
        }
}
