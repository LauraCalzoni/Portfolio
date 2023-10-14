from setuptools import setup
from glob import glob
import os

package_name = 'loc_and_nav'

setup(
    name=package_name,
    version='0.0.0',
    packages=[package_name],
    data_files=[
        ('share/ament_index/resource_index/packages',
            ['resource/' + package_name]),
        ('share/' + package_name, ['package.xml']),
        (os.path.join('share', package_name), glob('launch/*')),
    ],
    install_requires=['setuptools'],
    zip_safe=True,
    maintainer='luca',
    maintainer_email='luca@todo.todo',
    description='TODO: Package description',
    license='TODO: License declaration',
    tests_require=['pytest'],
    entry_points={
        'console_scripts': [
            'loc_and_nav = loc_and_nav.loc_and_nav:main',
            'localization = loc_and_nav.localization:main',
            'nav_to_pose = loc_and_nav.nav_to_pose:main',
        ],
    },
)
