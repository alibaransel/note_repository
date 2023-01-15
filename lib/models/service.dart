//TODO: Research and improve

abstract class Service {}

abstract class StartableService extends Service {
  void start();
}

abstract class StoppableService extends StartableService {
  void stop();
}
