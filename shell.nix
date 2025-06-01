{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    # Java Development
    jdk17
    gradle
    maven # Some tools might need it
    
    # Database Tools
    postgresql
    mysql80
    
    # Development Tools
   
    gnumake
    
    # Code Quality Tools
    checkstyle
    
    # Network Testing Tools
    netcat-gnu
    tcpdump
    wireshark
    
    # Protocol Testing Tools
    socat
    hexdump
    
    # JSON/XML Tools
    jq
    xmlstarlet
    
    # Documentation Tools
    pandoc
    
    # Container Tools (if needed for testing)
    docker
    docker-compose
    
    # Python (for tools directory scripts)
    python3
    python3Packages.pip
    python3Packages.requests
    
    # Node.js (for traccar-web if needed)
    nodejs
    yarn
    
    # Monitoring/Debugging
    htop
    lsof
  ];

  shellHook = ''
    echo "Traccar Development Environment"
    echo "================================"
    echo "Java version: $(java -version 2>&1 | head -n 1)"
    echo "Gradle version: $(gradle --version | grep Gradle | cut -d' ' -f2)"
    echo ""
    echo "Quick commands:"
    echo "  ./gradlew build          - Build the project"
    echo "  ./gradlew test           - Run tests"
    echo "  ./gradlew checkstyleMain - Run checkstyle"
    echo "  java -jar target/tracker-server.jar debug.xml - Run server"
    echo ""
    
    # Set JAVA_HOME
    export JAVA_HOME="${pkgs.jdk17}"
    
    # Add gradle wrapper to PATH if it exists
    if [ -f "./gradlew" ]; then
      export PATH="$PWD:$PATH"
    fi
    
    # Create local directories if they don't exist
    mkdir -p target
    mkdir -p logs
  '';

  # Environment variables
  JAVA_HOME = "${pkgs.jdk17}";
  GRADLE_USER_HOME = "./.gradle";
}