# Flo

## Assumptions
- I assume the sample file has formatting issues and should not line break at `1.` for example. According to the specs file it should look like:
```
Example: RecordIndicator,IntervalDate,IntervalValue1 . . . IntervalValueN,
QualityMethod,ReasonCode,ReasonDescription,UpdateDateTime,MSATSLoadDateTime
300,20030501,50.1, . . . ,21.5,V,,,20030101153445,20030102023012
```

## Installation
- Instal asdf https://asdf-vm.com/guide/getting-started.html
- Run `asdf install`

## Run tests
- Run `mix test`

## Run the code
- Run `iex -S mix`. This starts the REPL
- `Flo.process(<ABSOLUTE_PATH_TO_WHATEVER_NEM12_FILE_YOU_HAVE_LOCALLY>)`

## Additional Info
Q1. What are the advantages of the technologies you used for the project?
To be honest i choose Elixir because of familiarity. Some of its advatanges are:
- Code is really simple and easy to read. If you can undersstand this without having prior Elixir experience i would have succeeded.
- The advantage of Elixir (Erlang) is that its built for the sole purpose of being highly available and scalable. If we ever need to scale this because of high data velocity coming from source we can easily do so. If we have more sophisticated requirements (back pressure, rate limiting...) for data ingestion we can use https://github.com/dashbitco/broadway
- If data processing requires some hard core calculation Elixir can easily leverage on Rust https://fly.io/phoenix-files/elixir-and-rust-is-a-good-mix/
- Typically data ingestion runs as a cronjob. Instead of using Airflow one can use https://github.com/oban-bg/oban.

Q2. How is the code designed and structured?
- Its a typical 3 tier architecture https://vfunction.com/blog/3-tier-application/. In this case more like 2 tier because there not much of a pesentation tier. 
- you can say `Flo.process` is the entry point and also presentation tier
- `Flo.stream`, `Flo.generate_sql_statements` are the logic tier
- `SqlGenerator.batch_insert` is the data tier

Q3. How does the design help to make the codebase readable and maintainable for other engineers?
- Business logic tier take in data input and transform it into an internal reprsentation (MeterReading.ex) that lower layers e.g. data tier will use. So if there is anything dealing with validation or data transformation it should sit in the business logic tier
- Data tier takes in the internal representation and is in charge of generating the SQL statements. So if there is any tweak in the Database and statements need to be updated, it should be done here.
- Presentation tier takes care of how we present the SQL statements to the user. So if any change (e.g. formatting or output format) is require it should be done here.

Q4. Discuss any design patterns, coding conventions, or documentation practices you implemented to enhance readability and maintainability.
- Elixir is not a strongly typed language. There are tools however to have some type checking goodness. https://hexdocs.pm/elixir/typespecs.html  
Example: I frequently look at the function name and at the typespec and am already able to guess roughly what the code does. I do not need to look into the code body.
```
@spec process(String.t()) :: [String.t()]
  def process(absolute_path) do
  ...
```
- Recently there are in-roads made to do type checking on the fly. https://elixir-lang.org/blog/2024/12/19/elixir-v1-18-0-released/.

Q5. What would you do better next time?
- Performance enahcements can be made. E.g. batching insert statements together so that we can make fewer calls to the database saving on round trip time and database resource.
- Include performance testing so that we know for sure that by streaming, VM memory usage remains constant instead of exploding when faced with a large file. 

Q6. Reflect on areas where you see room for improvement and describe how you would approach them differently in future projects.
- I may choose to use Broadway (mentioned above) to do more efficient batching. Not sure if more efficient batching can be achieved easily using only Elixir native functions without code becoming unreadable.
- With Braodway there is dashboard that can monitor data pipeline to make sure nothing is exploding https://github.com/dashbitco/broadway_dashboard/ 
- Aside from that, i would probably write performance test as a separate repo because these test typically takes up resources and time. I would not want such tests to block more efficient CI workflow.

Q7. What other ways could you have done this project?
- JVM languages can definitely do a good job as well. The advantage of JVM lauguages is that it has a wide ecosystem. There will definitely be tools and libraries that can do the same that i've mentioned so far. My only gripe is that these tools and libraries usually become payware after a while. E.g. flyway.
- JVM was built with the intention of being a general programming language in mind. Hence its great for everything (and nothing). When it comes to spinning off new processes and managing them, its a pain. But i learn that with newer versions of JDK a lot of improvements have been made. So my knowledge is probably outdated. Erlang like i said is built with multi preocessing and high availability in mind hence its great at doing that efficiently.

Q8. Explore alternative approaches or technologies that you considered during the development of the project.
- Broadway like i mention is probably a better alternative if dzta ingestion requirement gets serious.
- For performance testing a very well known and often used tool is Gatling. I have seen non JVM projects using Gatling for performance testing simply because its too good.