# -----------------------------------------------------------
# Creates a Docker image by building and publishing 
# the source within the container
# -----------------------------------------------------------
# Build Docker image
FROM mcr.microsoft.com/dotnet/aspnet:8.0-jammy AS runtime

# Install wkhtmltopdf
RUN apt update \
	&& apt -y --no-install-recommends install \
		curl \
	&& curl -sSL https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.jammy_amd64.deb \
		-o /tmp/wkhtmltox_0.12.6.1-2.jammy_amd64.deb \ 
	&& apt -y --no-install-recommends install \
		/tmp/wkhtmltox_0.12.6.1-2.jammy_amd64.deb \
	&& rm /tmp/wkhtmltox_0.12.6.1-2.jammy_amd64.deb \
	&& rm -rf /var/lib/apt/lists/*

FROM mcr.microsoft.com/dotnet/sdk:8.0-jammy AS build

# Copy solution and source
ARG SOLUTION=Smartstore.sln
WORKDIR /app
COPY $SOLUTION ./
COPY Directory.Build.props ./
COPY proj.tgz /tmp/proj.tgz
RUN tar -xvzf /tmp/proj.tgz \
	&& rm /tmp/proj.tgz \
	&& dotnet restore --ucr
	# -s Smartstore/Smartstore.csproj -s Smartstore.Web.Common/Smartstore.Web.Common.csproj -s Smartstore.Web/Smartstore.Web.csproj

COPY src/ ./src
COPY test/ ./test
COPY nuget.config ./

# Create Modules dir if missing
RUN mkdir /app/src/Smartstore.Web/Modules -p -v

# Build
RUN dotnet build $SOLUTION -c Release

# Publish
WORKDIR /app/src/Smartstore.Web
RUN dotnet publish Smartstore.Web.csproj -c Release -o /app/release/publish \
	--no-self-contained \
	--no-restore

# Build Docker image
FROM runtime
EXPOSE 80
EXPOSE 443
ENV ASPNETCORE_URLS "http://+:80;https://+:443"
WORKDIR /app
COPY --from=build /app/release/publish .
COPY /packages .


ENTRYPOINT ["./Smartstore.Web", "--urls", "http://0.0.0.0:80"]