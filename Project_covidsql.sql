Select*
From PortfolioProject..CovidDeaths
Where continent is not Null
Order by 3,4

--Select*
--From PortfolioProject..CovidVaccinations
--Order by 3,4

--Selec Data that we are going to be using

Select location,date,total_cases,new_cases,total_deaths,population
From PortfolioProject..CovidDeaths
Order by 1,2

-- Looking at total cases Vs Total Deaths
-- Shows Likelihood of dying 

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%States%'
Order by 1,2

--Looking at Total cases vs Population
-- Shows What pecentage of population got Covid

Select location,date,total_cases,population,(total_cases/population)*100 as CovidPercentage
From PortfolioProject..CovidDeaths
Where location like '%Viet%'
Order by 1,2

-- Looking at the countries with heihgtest Infection Rate compared to Population
Select location,population,Max(total_cases)as HightestInfectionCount, Max(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location, population
Order by PercentPopulationInfected Desc

--Showing countries with Highest Death Count Perpopulation
Select location,Max(Cast(total_deaths as int))as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not Null
Group by location
Order by TotalDeathCount Desc

--Break Things down by Continent
Select continent,Max(Cast(total_deaths as int))as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not Null
Group by continent
Order by TotalDeathCount Desc

---Showing continents with highest death count per population
Select continent,Max(Cast(total_deaths as int))as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not Null
Group by continent
Order by TotalDeathCount Desc

---Global Numbers

Select date, sum(new_cases) as Total_Cases, Sum(cast(new_deaths as int)) as Total_Deaths,  Sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%States%'
Where continent is not null
Group by date
Order by 1,2

--Looking at total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by  dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths  dea
join PortfolioProject..CovidVaccinations vac
on dea.location =vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Use CTE

With PopvsVac (Continent,Location,Date,Population,New_Vaccinations, RollingPeopleVaccinated)

as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by  dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths  dea
join PortfolioProject..CovidVaccinations vac
on dea.location =vac.location
and dea.date = vac.date
where dea.continent is not null
)

Select* ,RollingPeopleVaccinated/Population*100
From PopvsVac

--temp Table
Drop table if exists #PercentPopulationVacinated
Create Table #PercentPopulationVacinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVacinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by  dea.date,dea.location) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths  dea
join PortfolioProject..CovidVaccinations vac
on dea.location =vac.location
and dea.date = vac.date
where dea.continent is not null

Select* ,RollingPeopleVaccinated/Population*100
From #PercentPopulationVacinated

-- Creating View to store data for Visualization later

--Population vs Vaccinnations

Create view PopulationvsVaccinations as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by  dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths  dea
join PortfolioProject..CovidVaccinations vac
on dea.location =vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

-- Countries with heihgtest Infection Rate compared to Population
Create view CountriesWithHighestInfectionRate as
Select location,population,Max(total_cases)as HightestInfectionCount, Max(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location, population
--Order by PercentPopulationInfected Desc