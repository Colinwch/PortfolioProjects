--Looking at all the columns of covid deaths data
SELECT *
FROM PortfolioProject..covid_deaths$


-- Selecting the columns that we are going to use from covid deaths data
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..covid_deaths$
ORDER BY Location,date


-- Looking at death percentages over time 
SELECT Location, date, total_cases, total_deaths, (CAST(total_deaths AS FLOAT)/CAST(total_cases AS FLOAT))*100 AS death_percentage
FROM PortfolioProject..covid_deaths$
ORDER BY Location, date


--Looking at countries with the highest infection rate
SELECT Location, population,MAX(CAST(total_cases AS INT)) AS Highest_infection_count, MAX((total_cases/population))*100 AS percent_population_infected
FROM PortfolioProject..covid_deaths$
WHERE continent IS NOT NULL
GROUP BY Location, population
ORDER BY Percent_population_infected DESC


--Looking at countries with highest death count per population
--Filtering out continents
SELECT Location,MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM PortfolioProject..covid_deaths$
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY total_death_count DESC 


--Looking at continent with highest death count
SELECT continent,MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM PortfolioProject..covid_deaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC 


--Global Numbers
SELECT date, SUM(new_cases) AS global_cases, SUM(CAST(new_deaths AS INT)) AS global_deaths, CASE	
	WHEN SUM(new_cases)>0 THEN SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 
	ELSE 0 
	END AS global_death_percentage
FROM PortfolioProject..covid_deaths$
WHERE continent IS NOT NULL
GROUP BY date


--Joining covid deaths data with vaccinations data
SELECT * 
FROM PortfolioProject..covid_deaths$ AS cd
JOIN PortfolioProject..covid_vaccinations$ AS cv
	ON cd.date = cv.date
	AND cd.location = cv.location


--Looking at vaccinations among populations using CTE
With PopulationvsVaccination (continent,Location, date, population,new_vaccinateions, rolling_vaccinated_population)
AS 
(
SELECT cd.continent, cd.location,cd.date, cd.population, CAST(cv.new_vaccinations AS FLOAT) AS new_vaccinations, SUM(CAST(cv.new_vaccinations AS FLOAT)) OVER (PARTITION BY cd.Location ORDER BY cv.location,cv.date) AS rolling_vaccinated_population
-- rolling_vaccinated_population/population)*100
FROM PortfolioProject..covid_deaths$ AS cd
JOIN PortfolioProject..covid_vaccinations$ AS cv
	ON cd.date = cv.date
	AND cd.location = cv.location
WHERE cd.continent IS NOT NULL
)
SELECT *, (rolling_vaccinated_population/population)*100 AS vaccinated_population
FROM PopulationvsVaccination


--Creating view for vaccinated_population_percentage
CREATE VIEW vaccinated_population_percentage AS
SELECT cd.continent, cd.location,cd.date, cd.population, CAST(cv.new_vaccinations AS FLOAT) AS new_vaccinations, SUM(CAST(cv.new_vaccinations AS FLOAT)) OVER (PARTITION BY cd.Location ORDER BY cv.location,cv.date) AS rolling_vaccinated_population
-- rolling_vaccinated_population/population)*100
FROM PortfolioProject..covid_deaths$ AS cd
JOIN PortfolioProject..covid_vaccinations$ AS cv
	ON cd.date = cv.date
	AND cd.location = cv.location
WHERE cd.continent IS NOT NULL

--Looking at the view created
SELECT * 
FROM vaccinated_population_percentage