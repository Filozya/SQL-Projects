/*
SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject1..CovidDeaths
ORDER BY 1,2

-- Change data type of total_cases to INT
ALTER TABLE PortfolioProject1..CovidDeaths
ALTER COLUMN total_cases FlOAT;

-- Change data type of total_deaths to INT
ALTER TABLE PortfolioProject1..CovidDeaths
ALTER COLUMN total_deaths FLOAT;
*/
--Looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country
SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--Looking at total cases vs population
--shows what percentage of population got covid
SELECT location,date,population,total_cases, (total_cases/population)*100 AS PercentOfPopulationInfected
FROM PortfolioProject1..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--Looking at Countries with heighest infection rate compared to population
SELECT location,population,MAX(total_cases) AS HeighestInfectionCount,MAX((total_cases/population))*100 AS RateOfInfection
FROM PortfolioProject1..CovidDeaths
WHERE continent is not NULL
GROUP BY location,population
ORDER BY RateOfInfection DESC

--shows countries with heighest death count per population
SELECT location,MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--shows continents with heighest death count per population
SELECT location,MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent is NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--showing global numbers
SELECT date,SUM(new_cases)as TotalCases,SUM(CAST(new_deaths as int)) as TotalDeaths,    100 * SUM(CAST(new_deaths as int)) / NULLIF(SUM(new_cases), 0) as DeathPercentage
FROM PortfolioProject1..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Looking at population vs vaccinations
SELECT dea.continent,dea.location,dea.date,population,vac.new_vaccinations,SUM(new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject1..CovidDeaths AS dea
join PortfolioProject1..CovidVaccination AS vac
ON dea.date=vac.date
AND dea.location=vac.location
WHERE dea.continent is not NULL
ORDER BY 2,3

