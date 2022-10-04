package dev.dorau.azurespringdbpasswordless

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class AzureSpringDbPasswordlessApplication

fun main(args: Array<String>) {
	runApplication<AzureSpringDbPasswordlessApplication>(*args)
}
