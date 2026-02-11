# InnowiseBigDataLab

Educational repository for Big Data engineering course.

> 📖 **New to programming?** Check out [SETUP_GUIDE.md](SETUP_GUIDE.md) for detailed step-by-step instructions!

## Quick Start

### Prerequisites
- Python 3.12+
- [uv](https://docs.astral.sh/uv/) package manager
- Docker & Docker Compose
- Git

### Installation

```bash
# 1. Install dependencies
uv sync

# 2. Activate virtual environment
source .venv/bin/activate  # macOS/Linux
.venv\Scripts\activate     # Windows

# 3. Setup environment variables
cp env.example .env
# Edit .env and change passwords!

# 4. Start Docker services
docker-compose up -d

# 5. Run tests
uv run pytest
```

## Development Workflow

### Code Quality
```bash
# Check code with linter
uv run ruff check .

# Auto-fix issues
uv run ruff check --fix .

# Format code
uv run ruff format .
```

### Testing
```bash
# Run all tests
uv run pytest

# Run with verbose output
uv run pytest -v

# Run specific test file
uv run pytest tests/test_main.py
```

### Git Workflow
```bash
# Enable pre-commit hook (optional but recommended)
git config core.hooksPath .github/hooks

# Make changes, then:
git add .
git commit -m "Your commit message"
git push
```

## Docker Services

After running `docker-compose up -d`, these services will be available:

| Service | URL | Description |
|---------|-----|-------------|
| PostgreSQL | `localhost:5432` | Database server |
| pgAdmin | http://localhost:5050 | Database management UI |
| JupyterLab | http://localhost:8888 | Interactive data science environment |

```bash
# View service status
docker-compose ps

# View logs
docker-compose logs

# Stop services
docker-compose stop

# Stop and remove containers
docker-compose down
```

## Project Structure

```
.
├── module_01_data_engineering_intro/
│   └── lecture_02_effective_development/
│       ├── homework/              # Your code here
│       ├── tests/                 # Your tests here
│       └── task_requirements.md   # Assignment description
├── module_02_from_event_to_data/
│   ├── lecture_02_databases/
│   └── lecture_03_sql_analysis/
├── module_03_data_ingestion/
│   └── lecture_02_python_for_ingestion/
├── module_04_data_processing/
│   ├── lecture_01_data_warehouse/
│   └── lecture_02_data_quality/
└── module_05_from_data_to_business/
    └── lecture_02_data_visualization/
```

## Documentation

- **[SETUP_GUIDE.md](SETUP_GUIDE.md)** - Detailed setup guide for beginners
- **[env.example](env.example)** - Environment variables template
- **[.github/hooks/README.md](.github/hooks/README.md)** - Git hooks documentation

## Useful Commands

```bash
# Check Python version
python3 --version

# Check uv version
uv --version

# List installed packages
uv pip list

# Update dependencies
uv sync

# Run Python script
uv run python module_01_data_engineering_intro/lecture_02_effective_development/homework/main.py
```

## Troubleshooting

### Common Issues

**"uv: command not found"**
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
# Restart terminal
```

**"Docker daemon not running"**
- Start Docker Desktop application

**"Port already in use"**
```bash
docker-compose down
# Or change port in docker-compose.yml
```

**ModuleNotFoundError**
```bash
# Ensure virtual environment is activated
source .venv/bin/activate
# Run through uv
uv run pytest
```

See [SETUP_GUIDE.md](SETUP_GUIDE.md) for more solutions.

## Contributing

1. Create a new branch: `git checkout -b feature/my-feature`
2. Make your changes
3. Run tests: `uv run pytest`
4. Run linter: `uv run ruff check .`
5. Commit: `git commit -m "Add feature"`
6. Push: `git push origin feature/my-feature`

## License

MIT License - see [LICENSE](LICENSE) file for details.

---

**Need help?** Read [SETUP_GUIDE.md](SETUP_GUIDE.md) for detailed instructions!
