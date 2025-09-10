SELECT * FROM CovidDeaths
WHERE continent is NOT NULL;

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2;

-- getting the datatypes of each columns

SELECT 
COLUMN_NAME,DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME='CovidDeaths';

-- total cases vs total deaths

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
FROM CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,5;

-- total cases vs population

SELECT location,date,total_cases,population,(total_cases/population)*100 as percentage
FROM CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,5;

-- countries with highest infection rate compared to population

SELECT location,MAX(total_cases) as highest_infecion_count,population,MAX(total_cases/population)*100 as percentage
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY location,population
ORDER BY percentage DESC;

-- countries with highest death count per population

SELECT location,MAX(CAST(total_deaths as INT)) as highest_death_count,population,MAX(total_deaths/population)*100 as percentage
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY location,population
ORDER BY 2 DESC;

-- continent with highest infection count

SELECT continent,MAX(total_cases) as highest_infecion_count,MAX(total_cases/population)*100 as percentage
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY percentage DESC;

-- continents with highest death count

SELECT continent,MAX(CAST(total_deaths AS INT)) as highest_death_count,MAX(total_deaths/population)*100 as percentage
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY 2 DESC;

-- total new cases and deaths on each day across the world

SELECT date,SUM(new_cases) as new_cases,SUM(CAST(new_deaths AS INT)) as new_deaths
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;

-- total population vs total vaccination

SELECT cd.continent,cd.location,cd.date,cv.new_vaccinations,cd.population,SUM(CONVERT(INT,cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.date) as total_vaccination_till_date
FROM CovidDeaths as cd
JOIN CovidVaccinations as cv
ON cd.location=cv.location
AND cd.date=cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2;

-- create CTE

WITH PopvsVacc(Continent,Location,Date,New_accination,Population,Total_vaccination_till_date)
as
(
SELECT cd.continent,cd.location,cd.date,cv.new_vaccinations,cd.population,SUM(CONVERT(INT,cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.date) as total_vaccination_till_date
FROM CovidDeaths as cd
JOIN CovidVaccinations as cv
ON cd.location=cv.location
AND cd.date=cv.date
WHERE cd.continent IS NOT NULL
)
SELECT *,(Total_vaccination_till_date/Population)*100 as Vaccination_percentage
FROM PopvsVacc;

-- create a temp table

DROP TABLE IF EXISTS #People_vaccinated
CREATE TABLE #People_vaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
New_vaccination numeric,
Population numeric,
Total_vaccination_till_date numeric);

INSERT INTO #People_vaccinated
SELECT cd.continent,cd.location,cd.date,cv.new_vaccinations,cd.population,SUM(CONVERT(INT,cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.date) as total_vaccination_till_date
FROM CovidDeaths as cd
JOIN CovidVaccinations as cv
ON cd.location=cv.location
AND cd.date=cv.date
WHERE cd.continent IS NOT NULL;

SELECT * FROM #People_vaccinated;

-- create a view

CREATE VIEW People_vaccinated AS
SELECT cd.continent,cd.location,cd.date,cv.new_vaccinations,cd.population,SUM(CONVERT(INT,cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.date) as total_vaccination_till_date
FROM CovidDeaths as cd
JOIN CovidVaccinations as cv
ON cd.location=cv.location
AND cd.date=cv.date
WHERE cd.continent IS NOT NULL;

SELECT * FROM People_vaccinated;

